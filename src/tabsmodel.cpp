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
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QStandardPaths>
#include <QUrl>

#include "browsermanager.h"
#include "angelfishsettings.h"

TabsModel::TabsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(this, &TabsModel::currentTabChanged, [this] {
        qDebug() << "Current tab changed to" << m_currentTab;
    });

    // The fallback tab must not be saved, it would overwrite our actual data.
    m_tabsReadOnly = true;
    // Make sure model always contains at least one tab
    createEmptyTab();
}

QHash<int, QByteArray> TabsModel::roleNames() const
{
    return {{RoleNames::UrlRole, QByteArrayLiteral("pageurl")}, {RoleNames::IsMobileRole, QByteArrayLiteral("isMobile")}};
}

QVariant TabsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_tabs.count()) {
        return {};
    }

    switch (role) {
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
 * @brief TabsModel::tab returns the tab at the given index
 * @param index
 * @return tab at the index
 */
TabState TabsModel::tab(int index)
{
    if (index < 0 && index >= m_tabs.count())
        return {}; // index out of bounds

    return m_tabs.at(index);
}

/**
 * @brief TabsModel::loadInitialTabs sets up the tabs that should already be open when starting the browser
 * This includes the configured homepage, an url passed on the command line (usually by another app) and tabs
 * which were still open when the browser was last closed.
 *
 * @warning It is impossible to save any new tabs until this function was called.
 */
void TabsModel::loadInitialTabs()
{
    if (!m_privateMode) {
        loadTabs();
    }

    m_tabsReadOnly = false;

    if (!m_privateMode) {
        if (BrowserManager::instance()->initialUrl().isEmpty()) {
            if (m_tabs.first().url() == QStringLiteral("about:blank"))
                setUrl(0, AngelfishSettings::self()->homepage());
        } else {
            if (m_tabs.first().url() == QStringLiteral("about:blank"))
                setUrl(0, BrowserManager::instance()->initialUrl());
            else
                newTab(BrowserManager::instance()->initialUrl());
        }
    }
}

/**
 * @brief TabsModel::currentTab returns the index of the tab that is currently visible to the user
 * @return index
 */
int TabsModel::currentTab() const
{
    return m_currentTab;
}

/**
 * @brief TabsModel::setCurrentTab sets the tab that is currently visible to the user
 * @param index
 */
void TabsModel::setCurrentTab(int index)
{
    if (index >= m_tabs.count())
        return;

    m_currentTab = index;
    emit currentTabChanged();
    saveTabs();
}

QVector<TabState> TabsModel::tabs() const
{
    return m_tabs;
}

/**
 * @brief TabsModel::loadTabs restores tabs saved in tabs.json
 * @return whether any tabs were restored
 */
bool TabsModel::loadTabs()
{
    if (!m_privateMode) {
        beginResetModel();
        QString input = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + QStringLiteral("/angelfish/tabs.json");

        QFile inputFile(input);
        if (!inputFile.exists()) {
            return false;
        }

        if (!inputFile.open(QIODevice::ReadOnly)) {
            qDebug() << "Failed to load tabs from disk";
        }

        const auto tabsStorage = QJsonDocument::fromJson(inputFile.readAll()).object();
        m_tabs.clear();
        const auto tabs = tabsStorage.value(QLatin1String("tabs")).toArray();
        for (const auto &tab : tabs) {
            m_tabs.append(TabState::fromJson(tab.toObject()));
        }

        qDebug() << "loaded from file:" << m_tabs.count() << input;

        m_currentTab = tabsStorage.value(QLatin1String("currentTab")).toInt();

        // Make sure model always contains at least one tab
        if (m_tabs.count() == 0) {
            createEmptyTab();
        }

        endResetModel();
        emit currentTabChanged();

        return true;
    }
    return false;
}

/**
 * @brief TabsModel::saveTabs saves the current state of the model to disk
 * @return whether the tabs could be saved
 */
bool TabsModel::saveTabs() const
{
    // only save if not in private mode
    if (!m_privateMode && !m_tabsReadOnly) {
        QString outputDir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + QStringLiteral("/angelfish/");

        QFile outputFile(outputDir + QStringLiteral("tabs.json"));
        if (!QDir(outputDir).mkpath(QStringLiteral("."))) {
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
        qDebug() << "Wrote to file" << outputFile.fileName() << "(" << tabsArray.count() << "urls"
                 << ")";

        tabsStorage.insert(QLatin1String("tabs"), tabsArray);
        tabsStorage.insert(QLatin1String("currentTab"), m_currentTab);

        document.setObject(tabsStorage);

        outputFile.write(document.toJson());
        return true;
    }
    return false;
}

bool TabsModel::isMobileDefault() const
{
    return m_isMobileDefault;
}

void TabsModel::setIsMobileDefault(bool def)
{
    m_isMobileDefault = def;
    emit isMobileDefaultChanged();

    // used in initialization of the tab
    if (m_tabs.count() == 1) {
        setIsMobile(0, def);
    }
}

bool TabsModel::privateMode() const
{
    return m_privateMode;
}

void TabsModel::setPrivateMode(bool privateMode)
{
    m_privateMode = privateMode;
    emit privateModeChanged();
}

/**
 * @brief TabsModel::createEmptyTab convinience function for opening a tab containing "about:blank"
 */
void TabsModel::createEmptyTab()
{
    newTab(QStringLiteral("about:blank"));
};

/**
 * @brief TabsModel::newTab
 * @param url
 * @param isMobile
 */
void TabsModel::newTab(const QString &url)
{
    beginInsertRows({}, m_tabs.count(), m_tabs.count());

    m_tabs.append(TabState(url, m_isMobileDefault));

    endInsertRows();

    // Switch to last tab
    m_currentTab = m_tabs.count() - 1;
    emit currentTabChanged();
    saveTabs();
}

/**
 * @brief TabsModel::closeTab removes the tab at the index, handles moving the tabs after it and sets a new currentTab
 * @param index
 */
void TabsModel::closeTab(int index)
{
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

    emit currentTabChanged();
    saveTabs();
}

void TabsModel::setIsMobile(int index, bool isMobile)
{
    qDebug() << "Setting isMobile:" << index << isMobile << "tabs open" << m_tabs.count();
    if (index < 0 && index >= m_tabs.count())
        return; // index out of bounds

    m_tabs[index].setIsMobile(isMobile);

    QModelIndex mindex = createIndex(index, index);
    emit dataChanged(mindex, mindex, {RoleNames::IsMobileRole});
    saveTabs();
}

void TabsModel::setUrl(int index, const QString &url)
{
    qDebug() << "Setting URL:" << index << url << "tabs open" << m_tabs.count();
    if (index < 0 && index >= m_tabs.count())
        return; // index out of bounds

    m_tabs[index].setUrl(url);

    QModelIndex mindex = createIndex(index, index);
    emit dataChanged(mindex, mindex, {RoleNames::UrlRole});
    saveTabs();
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
    return (m_url == other.url() && m_isMobile == other.isMobile());
}

QJsonObject TabState::toJson() const
{
    QJsonObject obj;
    obj.insert(QStringLiteral("url"), m_url);
    obj.insert(QStringLiteral("isMobile"), m_isMobile);
    return obj;
}
