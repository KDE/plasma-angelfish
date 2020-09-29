/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>           *
 *   SPDX-FileCopyrightText: 2020 Rinigus <rinigus.git@gmail.com>          *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later                             *
 *                                                                         *
 ***************************************************************************/

#ifndef USERAGENT_H
#define USERAGENT_H

#include <QObject>

class UserAgent : public QObject
{
    Q_PROPERTY(QString userAgent READ userAgent NOTIFY userAgentChanged)
    Q_PROPERTY(bool isMobile READ isMobile WRITE setIsMobile NOTIFY isMobileChanged)

    Q_OBJECT

public:
    explicit UserAgent(QObject *parent = nullptr);

    QString userAgent() const;

    bool isMobile() const;
    void setIsMobile(bool value);

signals:
    void isMobileChanged();
    void userAgentChanged();

private:
    bool m_isMobile;
};

#endif // USERAGENT_H
