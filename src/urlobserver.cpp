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

#include "urlobserver.h"
#include "browsermanager.h"

UrlObserver::UrlObserver(QObject *parent) : QObject(parent)
{
    connect(BrowserManager::instance(), &BrowserManager::databaseTableChanged,
            this, &UrlObserver::onDatabaseTableChanged);
}

QString UrlObserver::url() const
{
    return m_url;
}

void UrlObserver::setUrl(const QString &url)
{
    m_url = url;
    updateBookmarked();
    emit urlChanged(url);
}

bool UrlObserver::bookmarked() const
{
    return m_bookmarked;
}

void UrlObserver::onDatabaseTableChanged(const QString &table)
{
    if (table != QStringLiteral("bookmarks"))
        return;
    updateBookmarked();
}

void UrlObserver::updateBookmarked()
{
    bool b = BrowserManager::instance()->isBookmarked(m_url);
    if (b != m_bookmarked) {
        m_bookmarked = b;
        emit bookmarkedChanged(m_bookmarked);
    }
}
