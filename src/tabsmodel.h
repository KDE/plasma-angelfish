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

namespace AngelFish {

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
    Q_PROPERTY(bool isMobileDefault READ isMobileDefault WRITE setIsMobileDefault NOTIFY isMobileDefaultChanged)
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

    Q_INVOKABLE TabState tab(int index);

    Q_INVOKABLE void loadInitialTabs();

    Q_INVOKABLE void newTab(const QString &url);
    Q_INVOKABLE void createEmptyTab();
    Q_INVOKABLE void closeTab(int index);

    Q_INVOKABLE void setUrl(int index, const QString &url);
    Q_INVOKABLE void setIsMobile(int index, bool isMobile);

    bool isMobileDefault() const;
    void setIsMobileDefault(bool def);

    bool privateMode() const;
    void setPrivateMode(bool privateMode);

protected:
    bool loadTabs();
    bool saveTabs() const;

private:
    int m_currentTab = 0;
    QVector<TabState> m_tabs {};
    bool m_privateMode = false;
    bool m_tabsReadOnly = false;
    bool m_isMobileDefault = false;

signals:
    void currentTabChanged();
    void isMobileDefaultChanged();
    void privateModeChanged();
};

} // namespace

#endif // TABSMODEL_H
