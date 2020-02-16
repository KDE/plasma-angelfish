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
#include <QJsonObject>

class TabState {
public:
    static TabState fromJson(const QJsonObject &obj);
    QJsonObject toJson() const;

    TabState() = default;
    TabState(const QString &url, const bool isMobile);

    bool operator==(const TabState &other) const;

    bool isMobile() const;
    void setIsMobile(bool isMobile);

    QString url() const;
    void setUrl(const QString &url);

private:
    QString m_url;
    bool m_isMobile;
};

class TabsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int currentTab READ currentTab WRITE setCurrentTab NOTIFY currentTabChanged)
    Q_PROPERTY(bool privateMode READ privateMode WRITE setPrivateMode NOTIFY privateModeChanged)

    enum RoleNames {
        UrlRole = Qt::UserRole + 1,
        IsMobileRole
    };

public:
    explicit TabsModel(QObject *parent = nullptr);

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    int currentTab() const;
    void setCurrentTab(int index);

    QVector<TabState> tabs() const;

    Q_INVOKABLE void setTab(int index, const QString &url, bool isMobile = false);
    Q_INVOKABLE TabState tab(int index);

    Q_INVOKABLE void loadInitialTabs();

    Q_INVOKABLE void newTab(const QString &url, bool isMobile = false);
    Q_INVOKABLE void createEmptyTab();
    Q_INVOKABLE void closeTab(int index);
    Q_INVOKABLE void load(const QString &url);

    bool privateMode() const;
    void setPrivateMode(bool privateMode);

protected:
    bool loadTabs();
    bool saveTabs() const;

private:
    int m_currentTab = 0;
    QVector<TabState> m_tabs {};
    bool m_privateMode = false;

signals:
    void currentTabChanged();
    void tabsChanged();
    void privateModeChanged();
};

#endif // TABSMODEL_H
