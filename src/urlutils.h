/***************************************************************************
 *                                                                         *
 *   Copyright 2020 Jonah Brüchert  <jbb@kaidan.im>                        *
 *             2020 Rinigus <rinigus.git@gmail.com>                        *
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

#ifndef URLUTILS_H
#define URLUTILS_H

#include <QObject>

/**
 * @class UrlUtils
 * @short Utilities for URL manipulation and parsing.
 */
class UrlUtils : public QObject
{
    Q_OBJECT

public:
    UrlUtils(QObject *parent = nullptr);
    ~UrlUtils() override;

    Q_INVOKABLE static QString urlFromUserInput(const QString &input);
    Q_INVOKABLE static QString urlScheme(const QString &url);
    Q_INVOKABLE static QString urlHostPort(const QString &url);
    Q_INVOKABLE static QString urlPath(const QString &url);
};

#endif // URLUTILS_H
