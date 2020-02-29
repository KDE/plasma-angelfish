/***************************************************************************
 *   Copyright 2014 Sebastian Kügler <sebas@kde.org>                       *
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
 ***************************************************************************/

#include "browsermanager.h"

#include <QDebug>
#include <QUrl>
#include <QSettings>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

using namespace AngelFish;

BrowserManager *BrowserManager::s_instance = nullptr;

BrowserManager::BrowserManager(QObject *parent) : QObject(parent), m_settings(new QSettings(this))
{
    connect(&m_dbmanager, &DBManager::databaseTableChanged, this, &BrowserManager::databaseTableChanged);
}

BrowserManager::~BrowserManager()
{
    history()->save();
    bookmarks()->save();
}

UrlModel *BrowserManager::bookmarks()
{
    // qDebug() << "BookmarksManager::bookmarks()";
    if (!m_bookmarks) {
        m_bookmarks = new UrlModel(QStringLiteral("bookmarks.json"), this);
        m_bookmarks->load();
    }
    return m_bookmarks;
}

UrlModel *BrowserManager::history()
{
    // qDebug() << "BrowserManager::history()";
    if (!m_history) {
        m_history = new UrlModel(QStringLiteral("history.json"), this);
        m_history->load();
    }
    return m_history;
}

void BrowserManager::addBookmark(const QVariantMap &bookmarkdata)
{
    qDebug() << "Add bookmark";
    qDebug() << "      data: " << bookmarkdata;
    bookmarks()->add(QJsonObject::fromVariantMap(bookmarkdata));
    m_dbmanager.addBookmark(bookmarkdata);
}

void BrowserManager::removeBookmark(const QString &url)
{
    bookmarks()->remove(url);
    m_dbmanager.removeBookmark(url);
}

void BrowserManager::addToHistory(const QVariantMap &pagedata)
{
    // qDebug() << "Add History";
    // qDebug() << "      data: " << pagedata;
    history()->add(QJsonObject::fromVariantMap(pagedata));
    emit historyChanged();
    m_dbmanager.addToHistory(pagedata);
}

void BrowserManager::removeFromHistory(const QString &url)
{
    history()->remove(url);
    emit historyChanged();
    m_dbmanager.removeFromHistory(url);
}

void BrowserManager::lastVisited(const QString &url)
{
    m_dbmanager.lastVisited(url);
}

void BrowserManager::updateIcon(const QString &url, const QString &iconSource)
{
    m_dbmanager.updateIcon(url, iconSource);
}

void BrowserManager::setHomepage(const QString &homepage)
{
    m_settings->setValue("browser/homepage", homepage);
    emit homepageChanged();
}

QString BrowserManager::homepage()
{
    return m_settings->value("browser/homepage", "https://start.duckduckgo.com").toString();
}

void BrowserManager::setSearchBaseUrl(const QString &searchBaseUrl)
{
    m_settings->setValue("browser/searchBaseUrl", searchBaseUrl);
    emit searchBaseUrlChanged();
}

QString BrowserManager::initialUrl() const
{
    return m_initialUrl;
}

void BrowserManager::setInitialUrl(const QString &initialUrl)
{
    m_initialUrl = initialUrl;
}

QSettings *BrowserManager::settings() const
{
    return m_settings;
}

QString BrowserManager::searchBaseUrl()
{
    return m_settings->value("browser/searchBaseUrl", "https://start.duckduckgo.com/?q=")
            .toString();
}

BrowserManager *BrowserManager::instance()
{
    if (!s_instance)
        s_instance = new BrowserManager();

    return s_instance;
}
