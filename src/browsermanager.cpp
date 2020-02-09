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

BrowserManager::BrowserManager(QObject *parent) : QObject(parent), m_settings(new QSettings(this))
{
    loadTabs();
}

BrowserManager::~BrowserManager()
{
    history()->save();
    bookmarks()->save();
}

void BrowserManager::reload()
{
    qDebug() << "BookmarksManager::reload()";
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
}

void BrowserManager::removeBookmark(const QString &url)
{
    bookmarks()->remove(url);
}

void BrowserManager::addToHistory(const QVariantMap &pagedata)
{
    // qDebug() << "Add History";
    // qDebug() << "      data: " << pagedata;
    history()->add(QJsonObject::fromVariantMap(pagedata));
    emit historyChanged();
}

void BrowserManager::removeFromHistory(const QString &url)
{
    history()->remove(url);
    emit historyChanged();
}

QString BrowserManager::urlFromUserInput(const QString &input)
{
    return QUrl::fromUserInput(input).toString();
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

QString BrowserManager::searchBaseUrl()
{
    return m_settings->value("browser/searchBaseUrl", "https://start.duckduckgo.com/?q=")
            .toString();
}

int BrowserManager::currentTab() const
{
    return m_current_tab;
}

QString BrowserManager::tabs() const
{
    QJsonArray arr;
    for (auto i=m_tabs.constBegin(); i != m_tabs.constEnd(); ++i) {
        QJsonObject o;
        o["url"] = i->url;
        o["isMobile"] = i->isMobile;
        arr.append(o);
    }
    return QJsonDocument(arr).toJson();
}

void BrowserManager::loadTabs()
{
    QJsonArray arr = QJsonDocument::fromJson(m_settings->value("browser/tabs").toByteArray()).array();
    m_tabs.clear();
    for (auto i = arr.constBegin(); i != arr.constEnd(); ++i) {
        QJsonObject o = i->toObject();
        TabState ts(o.value("url").toString(), o.value("isMobile").toBool());
        m_tabs.push_back(ts);
    }
    m_current_tab = m_settings->value("browser/current_tab", 0).toInt();
}

void BrowserManager::saveTabs()
{
    m_settings->setValue("browser/tabs", tabs());
}

void BrowserManager::setCurrentTab(int index)
{
    if (m_tabs_readonly) return;
    m_current_tab = index;
    m_settings->setValue("browser/current_tab", m_current_tab);
}

void BrowserManager::setTab(int index, QString url, bool isMobile)
{
    if (m_tabs_readonly) return;
    while (m_tabs.length() <= index) {
        m_tabs.append(TabState());
    }
    m_tabs[index] = TabState(url, isMobile);
    saveTabs();
}

void BrowserManager::setTabIsMobile(int index, bool isMobile)
{
    TabState ts = m_tabs.value(index);
    setTab(index, ts.url, isMobile);
}

void BrowserManager::setTabUrl(int index, QString url)
{
    TabState ts = m_tabs.value(index);
    setTab(index, url, ts.isMobile);
}

void BrowserManager::setTabsWritable()
{
    m_tabs_readonly = false;
}

void BrowserManager::rmTab(int index)
{
    if (index >= 0 && index < m_tabs.size()) {
        m_tabs.removeAt(index);
        saveTabs();
    }
}
