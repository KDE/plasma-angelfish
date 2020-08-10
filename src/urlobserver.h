/***************************************************************************
 *                                                                         *
 *   Copyright 2020 Rinigus <rinigus.git@gmail.com>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
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
