/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>          *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
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
    if (table != QStringView(u"bookmarks"))
        return;

    updateBookmarked();
}

void UrlObserver::updateBookmarked()
{
    if (const bool isBookmarked = BrowserManager::instance()->isBookmarked(m_url); isBookmarked != m_bookmarked) {
        m_bookmarked = isBookmarked;
        emit bookmarkedChanged(m_bookmarked);
    }
}
