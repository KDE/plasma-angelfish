/*
 *  Copyright 2020 Jonah Brüchert <jbb@kaidan.im>
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License version 2 as published by the Free Software Foundation;
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public License
 *  along with this library; see the file COPYING.LIB.  If not, write to
 *  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301, USA.
 */

#include "tabsmodel.h"

#include <QDebug>
#include <QUrl>
#include <QStandardPaths>
#include <QFile>
#include <QJsonDocument>
#include <QDir>

#include "browsermanager.h"

TabsModel::TabsModel(QObject *parent) : QAbstractListModel(parent) {
    // We can only do this once we know whether we are in private mode or not
    connect(this, &TabsModel::privateModeChanged, [&] {
        loadTabs();
    });

    connect(this, &TabsModel::currentTabChanged, [this] {
        qDebug() << "Current tab changed to" << m_currentTab;
    });

    // Make sure model always contains at least one tab
    createEmptyTab();
}

QHash<int, QByteArray> TabsModel::roleNames() const
{
    return {
        { RoleNames::UrlRole, QByteArrayLiteral("pageurl") },
        { RoleNames::IsMobileRole, QByteArrayLiteral("isMobile") }
    };
}

QVariant TabsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_tabs.count()) {
        return {};
    }

    switch(role) {
    case RoleNames::UrlRole:
        return m_tabs.at(index.row()).url();
    case RoleNames::IsMobileRole:
        return m_tabs.at(index.row()).isMobile();
    }

    return {};
}

int TabsModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_tabs.count();
}

/**
 * @brief TabsModel::setTabUrl sets the url of a tab at a given index.
 * It should be used in cases were a reload of the web engine after the url change
 * is not wanted, e.g if this function is already triggered by a load of the web engine.
 * @param index
 * @param url
 * @param isMobile
 */
void TabsModel::setTab(int index, QString url, bool isMobile)
{
    if (index < 0 && index >= m_tabs.count())
        return; // index out of bounds

    m_tabs[index].setUrl(url);
    m_tabs[index].setIsMobile(isMobile);

    saveTabs();

    tabsChanged();
}

TabState TabsModel::tab(int index) {
    if (index < 0 && index >= m_tabs.count())
        return {}; // index out of bounds

    return m_tabs.at(index);
}

int TabsModel::currentTab() const
{
    return m_currentTab;
}

void TabsModel::setCurrentTab(int index)
{
    if (index >= m_tabs.count())
        return;

    m_currentTab = index;
    currentTabChanged();
    saveTabs();
}

QVector<TabState> TabsModel::tabs() const
{
    return m_tabs;
}

bool TabsModel::loadTabs()
{
    if (!m_privateMode) {
        beginResetModel();
        QString input = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
                    + QStringLiteral("/angelfish/tabs.json");

        QFile inputFile(input);
        if (!inputFile.exists()) {
            return false;
        }

        if (!inputFile.open(QIODevice::ReadOnly)) {
            qDebug() << "Failed to load tabs from disk";
        }

        const auto tabsStorage = QJsonDocument::fromJson(inputFile.readAll()).object();
        m_tabs.clear();
        for (const auto tab : tabsStorage.value(QLatin1String("tabs")).toArray()) {
            m_tabs.append(TabState::fromJson(tab.toObject()));
        }

        qDebug() << "loaded from file:" << m_tabs.count() << input;

        m_currentTab = tabsStorage.value(QLatin1String("currentTab")).toInt();

        // Make sure model always contains at least one tab
        if (m_tabs.count() == 0) {
            createEmptyTab();
        }

        endResetModel();
        tabsChanged();
        currentTabChanged();

        inputFile.close();

        return true;
    }
    return false;
}

bool TabsModel::saveTabs() const
{
    // only save if not in private mode
    if (!m_privateMode) {
        QString outputDir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
                    + QStringLiteral("/angelfish/");

        QFile outputFile(outputDir + QLatin1String("tabs.json"));
        if (!QDir(outputDir).mkpath(".")) {
            qDebug() << "Destdir doesn't exist and I can't create it: " << outputDir;
            return false;
        }
        if (!outputFile.open(QIODevice::WriteOnly)) {
            qDebug() << "Failed to write tabs to disk";
        }

        auto document = QJsonDocument();
        auto tabsStorage = QJsonObject();
        QJsonArray tabsArray;
        for (const auto &tab : m_tabs) {
            tabsArray.append(tab.toJson());
        }
        qDebug() << "Wrote to file" << outputFile.fileName() << "(" << tabsArray.count() << "urls" << ")";

        tabsStorage.insert(QLatin1String("tabs"), tabsArray);
        tabsStorage.insert(QLatin1String("currentTab"), m_currentTab);

        document.setObject(tabsStorage);

        outputFile.write(document.toJson());
        outputFile.close();
        return true;
    }
    return false;
}

bool TabsModel::privateMode() const
{
    return m_privateMode;
}

void TabsModel::setPrivateMode(bool privateMode)
{
    m_privateMode = privateMode;
    privateModeChanged();
}

void TabsModel::createEmptyTab()
{
    newTab(QStringLiteral("about:blank"));
};

void TabsModel::newTab(QString url, bool isMobile) {
    beginInsertRows({}, m_tabs.count(), m_tabs.count());

    QJsonObject tab;
    tab.insert(QStringLiteral("url"), url);
    m_tabs.append(TabState(url, isMobile));

    endInsertRows();

    // Switch to last tab
    m_currentTab = m_tabs.count() - 1;
    currentTabChanged();
}

void TabsModel::closeTab(int index) {
    if (index < 0 && index >= m_tabs.count())
        return; // index out of bounds

    if (m_tabs.count() <= 1) {
        // create new tab before removing the last one
        // to avoid linking all signals to null object
        createEmptyTab();

        // now we have (tab_to_remove, "about:blank)

        // 0 will be the correct current tab index after tab_to_remove is gone
        m_currentTab = 0;

        // index to remove
        index = 0;
    }

    if (m_currentTab > index) {
        // decrease index if it's after the removed tab
        m_currentTab--;
    }

    if (m_currentTab == index) {
        // handle the removal of current tab
        // Just reset to first tab
        m_currentTab = 0;
    }

    beginRemoveRows({}, index, index);
    m_tabs.removeAt(index);
    endRemoveRows();

    currentTabChanged();
    saveTabs();
}


/**
 * Load a url in the current tab
 */
void TabsModel::load(QString url) {
    qDebug() << "Loading url:" << url;

    qDebug() << "current tab" << m_currentTab << "tabs open" << m_tabs.count();
    m_tabs[m_currentTab].setUrl(url);

    QModelIndex index = createIndex(m_currentTab, m_currentTab);
    dataChanged(index, index);

    tabsChanged();
}

QString TabState::url() const
{
    return m_url;
}

void TabState::setUrl(const QString &url)
{
    m_url = url;
}

bool TabState::isMobile() const
{
    return m_isMobile;
}

void TabState::setIsMobile(bool isMobile)
{
    m_isMobile = isMobile;
}

TabState TabState::fromJson(const QJsonObject &obj)
{
    TabState tab;
    tab.setUrl(obj.value(QStringLiteral("url")).toString());
    tab.setIsMobile(obj.value(QStringLiteral("isMobile")).toBool());
    return tab;
}

TabState::TabState(const QString &url, const bool isMobile)
{
    setIsMobile(isMobile);
    setUrl(url);
}

bool TabState::operator==(const TabState &other) const
{
    return  (m_url == other.url() && m_isMobile == other.isMobile());
}

QJsonObject TabState::toJson() const
{
    QJsonObject obj;
    obj.insert(QStringLiteral("url"), m_url);
    obj.insert(QStringLiteral("isMobile"), m_isMobile);
    return obj;
}
