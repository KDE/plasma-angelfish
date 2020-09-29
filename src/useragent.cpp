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

#include "useragent.h"

#include <QtWebEngine/QQuickWebEngineProfile>
#include <QtWebEngine/QtWebEngineVersion>

UserAgent::UserAgent(QObject *parent)
    : QObject(parent)
    , m_isMobile(true)
{
}

QString UserAgent::userAgent() const
{
    return QStringLiteral(
               "Mozilla/5.0 (%1) AppleWebKit/537.36 (KHTML, like Gecko) QtWebEngine/%2 "
               "Chrome/75.0.3770.116 %3 Safari/537.36")
        .arg(m_isMobile ? QStringLiteral("Linux; Plasma Mobile, like Android 9.0") : QStringLiteral("X11; Linux x86_64"),
             QStringLiteral(QTWEBENGINE_VERSION_STR),
             m_isMobile ? QStringLiteral("Mobile") : QStringLiteral("Desktop"));
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
