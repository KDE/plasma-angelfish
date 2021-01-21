/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>           *
 *   SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>          *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
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

    Q_INVOKABLE static QString urlFromUserInput(const QString &input);
    Q_INVOKABLE static QString urlScheme(const QString &url);
    Q_INVOKABLE static QString urlHostPort(const QString &url);
    Q_INVOKABLE static QString urlHost(const QString &url);
    Q_INVOKABLE static QString htmlFormattedUrl(const QString &url);
};

#endif // URLUTILS_H
