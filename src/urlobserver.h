/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>          *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

#ifndef URLOBSERVER_H
#define URLOBSERVER_H

#include <QObject>
#include <QString>

class UrlObserver : public QObject
{
    Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(bool bookmarked READ bookmarked NOTIFY bookmarkedChanged)

    Q_OBJECT
public:
    explicit UrlObserver(QObject *parent = nullptr);

    QString url() const;
    void setUrl(const QString &url);

    bool bookmarked() const;

signals:
    void urlChanged(QString url);
    void bookmarkedChanged(bool bookmarked);

private:
    void onDatabaseTableChanged(const QString &table);
    void updateBookmarked();

private:
    QString m_url;
    bool m_bookmarked = false;
};

#endif // URLOBSERVER_H
