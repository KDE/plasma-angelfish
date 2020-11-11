/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>           *
 *   SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>          *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

#include "useragent.h"

#include <QtWebEngine/QQuickWebEngineProfile>
#include <QtWebEngine/QtWebEngineVersion>

UserAgent::UserAgent(QObject *parent)
    : QObject(parent)
    , m_defaultProfile(QQuickWebEngineProfile::defaultProfile())
    , m_chromeVersion(extractValueFromAgent("Chrome"))
    , m_appleWebKitVersion(extractValueFromAgent("AppleWebKit"))
    , m_webEngineVersion(extractValueFromAgent("QtWebEngine"))
    , m_safariVersion(extractValueFromAgent("Safari"))
    , m_isMobile(true)
{
}

QString UserAgent::userAgent() const
{
    return QStringLiteral(
               "Mozilla/5.0 (%1) AppleWebKit/%2 (KHTML, like Gecko) QtWebEngine/%3 "
               "Chrome/%4 %5 Safari/%6")
        .arg(m_isMobile ? QStringLiteral("Linux; Plasma Mobile, like Android 9.0") : QStringLiteral("X11; Linux x86_64"),
             m_appleWebKitVersion,
             m_webEngineVersion,
             m_chromeVersion,
             m_isMobile ? u"Mobile" : u"Desktop",
             m_safariVersion);
}

bool UserAgent::isMobile() const
{
    return m_isMobile;
}

void UserAgent::setIsMobile(bool value)
{
    if (m_isMobile != value) {
        m_isMobile = value;

        emit isMobileChanged();
        emit userAgentChanged();
    }
}

QString UserAgent::extractValueFromAgent(const std::string &key)
{
    const std::string defaultUserAgent = m_defaultProfile->httpUserAgent().toStdString();
    const unsigned long index = defaultUserAgent.find(key) + key.length() + 1;
    const unsigned long endIndex = defaultUserAgent.find(' ', index);
    return QString::fromStdString(defaultUserAgent.substr(index, endIndex - index));
}
