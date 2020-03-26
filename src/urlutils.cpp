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

#include "urlutils.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSettings>
#include <QUrl>

UrlUtils::UrlUtils(QObject *parent)
    : QObject(parent)
{
}

UrlUtils::~UrlUtils()
{
}

QString UrlUtils::urlFromUserInput(const QString &input)
{
    return QUrl::fromUserInput(input).toString();
}

QString UrlUtils::urlScheme(const QString &url)
{
    return QUrl::fromUserInput(url).scheme();
}

QString UrlUtils::urlHostPort(const QString &url)
{
    QUrl u(url);
    QString r = u.host();
    QStringList common = { QLatin1String("www."),
                           QLatin1String("m."),
                           QLatin1String("mobile.") };
    for (const auto &i: common) {
        if (r.startsWith(i) && r.length() > i.length()) {
            r.remove(0, i.length());
            break; // strip prefix only once
        }
    }

    int p = u.port(-1);
    if (p > 0)
        r = QStringLiteral("%1:%2").arg(r).arg(p);
    return r;
}

QString UrlUtils::urlPath(const QString &url)
{
    return QUrl::fromUserInput(url).path();
}

QString UrlUtils::urlHost(const QString &url)
{
    return QUrl::fromUserInput(url).host();
}
