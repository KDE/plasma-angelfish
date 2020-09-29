/*
 *  SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 *
 *  SPDX-License-Identifier: LGPL-2.0-only
 */

#include <QtGlobal>
#include <QByteArrayList>
#include <QDebug>

#include "settingshelper.h"

bool SettingsHelper::isMobile()
{
    static bool mobile = qEnvironmentVariableIsSet("QT_QUICK_CONTROLS_MOBILE")
                             ? QByteArrayList{"1", "true"}.contains(qgetenv("QT_QUICK_CONTROLS_MOBILE"))
                             : false;
    return mobile;
}
