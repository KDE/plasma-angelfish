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

#ifndef TABSMODEL_H
#define TABSMODEL_H

#include <QAbstractListModel>
#include <QSettings>

class TabsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int currentTab READ currentTab WRITE setCurrentTab NOTIFY currentTabChanged)
    Q_PROPERTY(QList<QString> tabs READ tabs NOTIFY tabsChanged)
    Q_PROPERTY(bool privateMode READ privateMode WRITE setPrivateMode NOTIFY privateModeChanged)
    Q_PROPERTY(bool tabsWritable READ tabsWritable WRITE setTabsWritable NOTIFY tabsWritableChanged)

    enum RoleNames {
        UrlRole = Qt::UserRole + 1
    };

public:
    explicit TabsModel(QObject *parent = nullptr, QSettings *settings = nullptr);

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    int currentTab() const;

    QList<QString> tabs() const;

    void setCurrentTab(int index);
    Q_INVOKABLE void setTab(int index, QString url);

    Q_INVOKABLE void newTab(QString url);
    Q_INVOKABLE void createEmptyTab();
    Q_INVOKABLE void closeTab(int index);
    Q_INVOKABLE void load(QString url);

    bool privateMode() const;
    void setPrivateMode(bool privateMode);

    bool tabsWritable() const;
    void setTabsWritable(bool writable);

protected:
    void loadTabs();
    void saveTabs();

private:
    QSettings *m_settings {};

    int m_currentTab = 0;
    QList<QString> m_tabs;
    bool m_tabsWritable = true;
    bool m_privateMode = false;

signals:
    void currentTabChanged();
    void tabsChanged();
    void privateModeChanged();
    void tabsWritableChanged();
};

#endif // TABSMODEL_H
