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

TabsModel::TabsModel(QObject *parent, QSettings *settings) : QAbstractListModel(parent),
    m_settings(settings)
{
    connect(this, &TabsModel::privateModeChanged, [&] {
        if (!m_privateMode) {
            loadTabs();
        }
    });

    connect(this, &TabsModel::currentTabChanged, [this] {
        qDebug() << m_currentTab;
    });

    // HACK
    // TODO
    // REMOVE
    m_settings = new QSettings(this);

    createEmptyTab();
}

QHash<int, QByteArray> TabsModel::roleNames() const
{
    return {
        { RoleNames::UrlRole, QByteArrayLiteral("pageurl") }
    };
}

QVariant TabsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_tabs.count()) {
        return {};
    }

    switch(role) {
    case RoleNames::UrlRole:
        return QUrl(m_tabs.at(index.row()));
    }

    return {};
}

int TabsModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_tabs.count();
}

void TabsModel::setTab(int index, QString url)
{
    if (!m_tabsWritable)
        return;

    while (m_tabs.length() <= index) {
        m_tabs.append(QString());
    }
    m_tabs[index] = url;
    saveTabs();

    tabsChanged();
}

bool TabsModel::tabsWritable() const
{
    return m_tabsWritable;
}

void TabsModel::setTabsWritable(bool writable)
{
    m_tabsWritable = writable;
}

int TabsModel::currentTab() const
{
    return m_currentTab;
}

void TabsModel::setCurrentTab(int index)
{
    if (!m_tabsWritable)
        return;

    if (index >= m_tabs.count())
        return;

    m_currentTab = index;
    currentTabChanged();
    saveTabs();
}

QList<QString> TabsModel::tabs() const
{
    return m_tabs;
}

void TabsModel::loadTabs()
{
    m_tabs = m_settings->value(QStringLiteral("browser/tabs"), QStringList()).toStringList();
    m_currentTab = m_settings->value(QStringLiteral("browser/current_tab"), 0).toInt();
    tabsChanged();
    currentTabChanged();
}

void TabsModel::saveTabs()
{
    // only save if not in private mode
    if (!m_privateMode) {
        m_settings->setValue(QStringLiteral("browser/tabs"), QVariant(m_tabs));
        m_settings->setValue(QStringLiteral("browser/current_tab"), m_currentTab);
    }
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

void TabsModel::newTab(QString url) {
    beginInsertRows({}, m_tabs.count(), m_tabs.count());
    m_tabs.append(url);
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
        // decrease index if its after the removed tab
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

    beginRemoveRows({}, m_currentTab, m_currentTab);
    endRemoveRows();

    beginInsertRows({}, m_currentTab, m_currentTab);

    qDebug() << m_tabs;
    m_tabs.replace(m_currentTab, url);

    endInsertRows();

    tabsChanged();
}
