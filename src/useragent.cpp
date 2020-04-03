#include "useragent.h"

#include <QtWebEngine/QQuickWebEngineProfile>
#include <QtWebEngine/QtWebEngineVersion>

UserAgent::UserAgent(QObject *parent)
    : QObject(parent)
{
}

QString UserAgent::userAgent() const
{
    return QStringLiteral(
               "Mozilla/5.0 (%1) AppleWebKit/537.36 (KHTML, like Gecko) QtWebEngine/%2 "
               "Chrome/75.0.3770.116 %3 Safari/537.36")
        .arg(m_isMobile ? QStringLiteral("Linux; Plasma Mobile, like Android 9.0") : QStringLiteral("X11; Linux x86_64"))
        .arg(QStringLiteral(QTWEBENGINE_VERSION_STR))
        .arg(m_isMobile ? QStringLiteral("Mobile") : QStringLiteral("Desktop"));
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
