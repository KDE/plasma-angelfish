/***************************************************************************
 *                                                                         *
 *   Copyright 2020 Jonah Brüchert  <jbb@kaidan.im>                        *
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

#ifndef DESKTOPFILEGENERATOR_H
#define DESKTOPFILEGENERATOR_H

#include <QObject>
class QQmlEngine;

class DesktopFileGenerator : public QObject
{
    Q_OBJECT
public:
    explicit DesktopFileGenerator(QQmlEngine *engine, QObject *parent = nullptr);

    Q_INVOKABLE void createDesktopFile(const QString &name, const QString &url, const QString &icon);

private:
    void storeIcon(const QString &url, const QString &fileName);
    QString webappCommand();
    QQmlEngine *m_engine;
};

#endif // DESKTOPFILEGENERATOR_H
