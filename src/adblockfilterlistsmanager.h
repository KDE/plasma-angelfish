// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QNetworkAccessManager>

class AdblockFilterListsManager : public QObject
{
    Q_OBJECT

public:
    AdblockFilterListsManager(QObject *parent = nullptr);

    struct FilterList {
        QString name;
        QUrl url;
    };

    /// filterListPath always returns an existing path to a filter list directory
    static QString filterListPath();
    /// publicSuffixListPath always returns a an existing path to which a public suffix list can be written
    static QString publicSuffixListPath();

    void refreshLists();
    Q_SIGNAL void refreshFinished();

    const QVector<FilterList> &filterLists() const;

    void addFilterList(const QString &name, const QUrl &url);
    void removeFilterList(const int index);

private:
    Q_SLOT void handleListFetched(QNetworkReply *reply);

    static QVector<FilterList> loadFromConfig();
    static void writeToConfig(const QVector<FilterList> &filters);

    QVector<FilterList> m_filterLists;
    QNetworkAccessManager m_networkManager;
    int m_runningRequests;
};
