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
#include <QQmlPropertyMap>

#include "urlmodel.h"

class QSettings;

namespace AngelFish {
/**
 * @class BookmarksManager
 * @short Access to Bookmarks and History. This is a singleton for
 * administration and access to the various models and browser-internal
 * data.
 */
class BrowserManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QAbstractListModel *bookmarks READ bookmarks NOTIFY bookmarksChanged)
    Q_PROPERTY(QAbstractListModel *history READ history NOTIFY historyChanged)

    Q_PROPERTY(QString homepage READ homepage WRITE setHomepage NOTIFY homepageChanged)
    Q_PROPERTY(QString searchBaseUrl READ searchBaseUrl WRITE setSearchBaseUrl NOTIFY
                       searchBaseUrlChanged)

public:
    BrowserManager(QObject *parent = nullptr);
    ~BrowserManager() override;

    UrlModel *bookmarks();
    UrlModel *history();

    QString homepage();
    QString searchBaseUrl();

    Q_INVOKABLE static QString urlFromUserInput(const QString &input);

signals:
    void updated();
    void bookmarksChanged();
    void historyChanged();

    void homepageChanged();
    void searchBaseUrlChanged();

    void loadUrlRequested(const QString &url);

public slots:
    void reload();

    void addBookmark(const QVariantMap &bookmarkdata);
    void removeBookmark(const QString &url);

    void addToHistory(const QVariantMap &pagedata);
    void removeFromHistory(const QString &url);

    void setHomepage(const QString &homepage);
    void setSearchBaseUrl(const QString &searchBaseUrl);

private:
    UrlModel *m_bookmarks = nullptr;
    UrlModel *m_history = nullptr;
    QSettings *m_settings;
};

} // namespace

#endif // BOOKMARKSMANAGER_H
