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

#include <QtGlobal>
#include <QByteArrayList>

#include "settingshelper.h"

SettingsHelper *SettingsHelper::s_instance = nullptr;

SettingsHelper *SettingsHelper::instance()
{
    if (!s_instance)
        s_instance = new SettingsHelper();

    return s_instance;
}

SettingsHelper::SettingsHelper()
{
    m_isMobile = qEnvironmentVariableIsSet("QT_QUICK_CONTROLS_MOBILE") ? QByteArrayList{"1", "true"}.contains(qgetenv("QT_QUICK_CONTROLS_MOBILE")) : false;
}
