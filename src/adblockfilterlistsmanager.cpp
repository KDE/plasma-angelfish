// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "adblockfilterlistsmanager.h"

#include <QDir>
#include <QFile>
#include <QNetworkReply>
#include <QStandardPaths>

#include "angelfishsettings.h"

static const QString PUBLIC_SUFFIX_LIST_URL = QStringLiteral("https://raw.githubusercontent.com/publicsuffix/list/master/public_suffix_list.dat");

AdblockFilterListsManager::AdblockFilterListsManager(QObject *parent)
    : QObject(parent)
    , m_filterLists(loadFromConfig())
{
    connect(&m_networkManager, &QNetworkAccessManager::finished, this, &AdblockFilterListsManager::handleListFetched);
    m_networkManager.setRedirectPolicy(QNetworkRequest::SameOriginRedirectPolicy);
}

void AdblockFilterListsManager::refreshLists()
{
    for (const auto &list : std::as_const(m_filterLists)) {
        m_runningRequests++;
        m_networkManager.get(QNetworkRequest(list.url));
    }

    m_runningRequests++;
    m_networkManager.get(QNetworkRequest(PUBLIC_SUFFIX_LIST_URL));
}

QString AdblockFilterListsManager::filterListPath()
{
    static const QString path = []() {
        const auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QStringLiteral("/filterlists/");
        QDir(path).mkpath(QStringLiteral("."));
        return path;
    }();
    return path;
}

QString AdblockFilterListsManager::publicSuffixListPath()
{
    static const QString path = []() {
        const auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir(path).mkpath(QStringLiteral("."));
        return path + QStringLiteral("/publicsuffixlist.txt");
    }();
    return path;
}

void AdblockFilterListsManager::handleListFetched(QNetworkReply *reply)
{
    m_runningRequests--;

    if (m_runningRequests < 1) {
        Q_EMIT refreshFinished();
    }

    if (reply->url() == PUBLIC_SUFFIX_LIST_URL) {
        QFile file(publicSuffixListPath());
        if (!file.open(QIODevice::WriteOnly)) {
            qDebug() << "Failed to open" << file.fileName() << "for writing";
            return;
        }
        file.write(reply->readAll());
    } else {
        QFile file(filterListPath() + reply->url().fileName());
        if (!file.open(QIODevice::WriteOnly)) {
            qDebug() << "Failed to open" << file.fileName() << "for writing."
                     << "Filter list not updated";
            return;
        }
        file.write(reply->readAll()); // TODO don't read everything into memory maybe
    }
}

QVector<AdblockFilterListsManager::FilterList> AdblockFilterListsManager::loadFromConfig()
{
    const auto &filterNames = AngelfishSettings::adblockFilterNames();
    const auto &filterUrls = AngelfishSettings::adblockFilterUrls();

    auto namesIt = filterNames.begin();
    auto urlsIt = filterUrls.begin();

    QVector<AdblockFilterListsManager::FilterList> out;

    // Otherwise list is corrupted, but we will still not crash in release mode
    Q_ASSERT(filterNames.size() == filterUrls.size());

    while (namesIt != filterNames.end() && urlsIt != filterUrls.end()) {
        out.push_back(FilterList {*namesIt, *urlsIt});

        namesIt++;
        urlsIt++;
    }

    return out;
}

void AdblockFilterListsManager::writeToConfig(const QVector<AdblockFilterListsManager::FilterList> &filters)
{
    QStringList filterNames;
    QList<QUrl> filterUrls;

    for (const auto &filterList : filters) {
        filterNames.push_back(filterList.name);
        filterUrls.push_back(filterList.url);
    }

    AngelfishSettings::setAdblockFilterNames(filterNames);
    AngelfishSettings::setAdblockFilterUrls(filterUrls);
}

const QVector<AdblockFilterListsManager::FilterList> &AdblockFilterListsManager::filterLists() const
{
    return m_filterLists;
}

void AdblockFilterListsManager::addFilterList(const QString &name, const QUrl &url)
{
    m_filterLists.push_back(FilterList {name, url});
    writeToConfig(m_filterLists);
}

void AdblockFilterListsManager::removeFilterList(const int index)
{
    m_filterLists.removeAt(index);
    writeToConfig(m_filterLists);
}
