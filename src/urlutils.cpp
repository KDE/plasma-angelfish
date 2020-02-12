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
#include <QUrl>
#include <QSettings>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

using namespace AngelFish;

UrlUtils::UrlUtils(QObject *parent) : QObject(parent)
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
    int p = u.port(-1);
    if (p > 0) r = QString("%1:%2").arg(r).arg(p);
    return r;
}

QString UrlUtils::urlPath(const QString &url)
{
    return QUrl::fromUserInput(url).path();
}

