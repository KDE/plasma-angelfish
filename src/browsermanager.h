/***************************************************************************
 *                                                                         *
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
 *                                                                         *
 ***************************************************************************/

#ifndef BOOKMARKSMANAGER_H
#define BOOKMARKSMANAGER_H

#include <QObject>

#include "dbmanager.h"

class QSettings;

/**
 * @class BookmarksManager
 * @short Access to Bookmarks and History. This is a singleton for
 * administration and access to the various models and browser-internal
 * data.
 */
class BrowserManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString homepage READ homepage WRITE setHomepage NOTIFY homepageChanged)
    Q_PROPERTY(QString searchBaseUrl READ searchBaseUrl WRITE setSearchBaseUrl NOTIFY
                       searchBaseUrlChanged)

    Q_PROPERTY(QString initialUrl READ initialUrl WRITE setInitialUrl NOTIFY initialUrlChanged)

public:
    ~BrowserManager() override;

    static BrowserManager *instance();

    QString homepage();
    QString searchBaseUrl();

    QSettings* settings() const;

    QString initialUrl() const;
    void setInitialUrl(const QString &initialUrl);

signals:
    void updated();

    void homepageChanged();
    void searchBaseUrlChanged();
    void initialUrlChanged();

    void databaseTableChanged(QString table);

public slots:
    void addBookmark(const QVariantMap &bookmarkdata);
    void removeBookmark(const QString &url);

    void addToHistory(const QVariantMap &pagedata);
    void removeFromHistory(const QString &url);

    void lastVisited(const QString &url);
    void updateIcon(const QString &url, const QString &iconSource);

    void setHomepage(const QString &homepage);
    void setSearchBaseUrl(const QString &searchBaseUrl);

private:
    // BrowserManager should only be createdd by calling the instance() function
    BrowserManager(QObject *parent = nullptr);

    DBManager m_dbmanager;

    QSettings *m_settings;

    QString m_initialUrl;

    static BrowserManager *s_instance;
};

#endif // BOOKMARKSMANAGER_H
