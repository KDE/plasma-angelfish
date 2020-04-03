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
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSettings>
#include <QUrl>

BrowserManager *BrowserManager::s_instance = nullptr;

BrowserManager::BrowserManager(QObject *parent)
    : QObject(parent)
    , m_dbmanager(new DBManager)
    , m_settings(new QSettings(this))
{
    connect(m_dbmanager, &DBManager::databaseTableChanged, this, &BrowserManager::databaseTableChanged);
}

BrowserManager::~BrowserManager()
{
}

void BrowserManager::addBookmark(const QVariantMap &bookmarkdata)
{
    qDebug() << "Add bookmark";
    qDebug() << "      data: " << bookmarkdata;
    m_dbmanager->addBookmark(bookmarkdata);
}

void BrowserManager::removeBookmark(const QString &url)
{
    m_dbmanager->removeBookmark(url);
}

void BrowserManager::addToHistory(const QVariantMap &pagedata)
{
    // qDebug() << "Add History";
    // qDebug() << "      data: " << pagedata;
    m_dbmanager->addToHistory(pagedata);
}

void BrowserManager::removeFromHistory(const QString &url)
{
    m_dbmanager->removeFromHistory(url);
}

void BrowserManager::updateLastVisited(const QString &url)
{
    m_dbmanager->updateLastVisited(url);
}

void BrowserManager::updateIcon(const QString &url, const QString &iconSource)
{
    m_dbmanager->updateIcon(url, iconSource);
}

void BrowserManager::setHomepage(const QString &homepage)
{
    if (this->homepage() == homepage)
        return;
    m_settings->setValue(QStringLiteral("browser/homepage"), homepage);
    emit homepageChanged();
}

QString BrowserManager::homepage()
{
    return m_settings->value(QStringLiteral("browser/homepage"), QStringLiteral("https://start.duckduckgo.com")).toString();
}

void BrowserManager::setSearchBaseUrl(const QString &searchBaseUrl)
{
    if (this->searchBaseUrl() == searchBaseUrl)
        return;
    m_settings->setValue(QStringLiteral("browser/searchBaseUrl"), searchBaseUrl);
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
    return m_settings->value(QStringLiteral("browser/searchBaseUrl"), QStringLiteral("https://start.duckduckgo.com/?q=")).toString();
}

BrowserManager *BrowserManager::instance()
{
    if (!s_instance)
        s_instance = new BrowserManager();

    return s_instance;
}
