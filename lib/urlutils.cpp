/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>           *
 *   SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>          *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
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

UrlUtils::~UrlUtils() = default;

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
    const QUrl u(url);
    static QStringList common = { QLatin1String("www."),
                           QLatin1String("m."),
                           QLatin1String("mobile.") };

    QString r = u.host();
    for (const auto &i : common) {
        if (r.startsWith(i) && r.length() > i.length()) {
            r.remove(0, i.length());
            break; // strip prefix only once
        }
    }

    const int p = u.port(-1);

    if (p > 0)
        r = QStringLiteral("%1:%2").arg(r).arg(p);

    return r;
}

QString UrlUtils::urlHost(const QString &url)
{
    return QUrl::fromUserInput(url).host();
}

QString UrlUtils::htmlFormattedUrl(const QString &url)
{
    const QUrl parsedUrl = QUrl::fromUserInput(url);

    const QString path = parsedUrl.path();
    return QStringLiteral(R"(%1<font size="2">%2</font>)")
            .arg(parsedUrl.host(),
                 path == QStringLiteral("/") ? QString() : path);
}
