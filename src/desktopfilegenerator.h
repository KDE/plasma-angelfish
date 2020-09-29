/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>           *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
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
    Q_INVOKABLE bool desktopFileExists(const QString &name);
    Q_INVOKABLE bool removeDesktopFile(const QString &name);

private:
    void storeIcon(const QString &url, const QString &fileName);
    QString generateFileName(const QString &name);
    QString webappCommand();
    QQmlEngine *m_engine;
};

#endif // DESKTOPFILEGENERATOR_H
