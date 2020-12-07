// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "adblockurlinterceptor.h"

#include <QQuickWebEngineProfile>
#include <QDebug>
#include <QDir>
#include <QStandardPaths>

#include "adblockfilterlistsmanager.h"

#ifdef BUILD_ADBLOCK
class Engine;
#include "rs/adblock/bindings.h"
#include "angelfishsettings.h"
#endif

#include <future>

#include <QLoggingCategory>
Q_LOGGING_CATEGORY(AdblockCategory, "org.kde.mobile.angelfish.adblock", QtWarningMsg);

AdblockUrlInterceptor::AdblockUrlInterceptor(QObject *parent)
    : QWebEngineUrlRequestInterceptor(parent)
#ifdef BUILD_ADBLOCK
    // parsing the block lists takes some time, try to do it asynchronously
    // if it is not ready when it's needed, reading the future will block
    , m_adblockInitFuture(std::async(std::launch::async, [this]() -> Adblock *{
          const auto filterListsPath = AdblockFilterListsManager::filterListPath().toStdString();
          const auto publicSuffixList = AdblockFilterListsManager::publicSuffixListPath().toStdString();

          auto *adb = new_adblock(filterListsPath.c_str(), publicSuffixList.c_str());
          Q_EMIT adblockInitialized();
          return adb;
      }))
    , m_adblock(nullptr)
    , m_enabled(AngelfishSettings::adblockEnabled())
#endif
{
#ifdef BUILD_ADBLOCK
    connect(this, &AdblockUrlInterceptor::adblockInitialized, this, [this] {
        if (m_adblockInitFuture.valid()) {
            m_adblock = m_adblockInitFuture.get();
        }
    });
#endif
}

AdblockUrlInterceptor::~AdblockUrlInterceptor()
{
#ifdef BUILD_ADBLOCK
    free_adblock(m_adblock);
#endif
}

#ifdef BUILD_ADBLOCK
bool AdblockUrlInterceptor::enabled() const
{
    return m_enabled;
}

void AdblockUrlInterceptor::setEnabled(bool enabled)
{
    m_enabled = enabled;
    AngelfishSettings::setAdblockEnabled(enabled);
}
#endif

AdblockUrlInterceptor &AdblockUrlInterceptor::instance()
{
    static AdblockUrlInterceptor instance;

    return instance;
}

void AdblockUrlInterceptor::manageProfile(QQuickWebEngineProfile *profile)
{
    profile->setUrlRequestInterceptor(this);
}

bool AdblockUrlInterceptor::downloadNeeded() const
{
    return QDir(AdblockFilterListsManager::filterListPath()).isEmpty();
}

void AdblockUrlInterceptor::resetAdblock()
{
#ifdef BUILD_ADBLOCK
    if (m_adblock) {
        free_adblock(m_adblock);
        m_adblock = nullptr;
    }
    m_adblockInitFuture = std::async(std::launch::async, [this]() -> Adblock * {
        const auto filterListsPath = AdblockFilterListsManager::filterListPath().toStdString();
        const auto publicSuffixList = AdblockFilterListsManager::publicSuffixListPath().toStdString();

        auto *adb = new_adblock(filterListsPath.c_str(), publicSuffixList.c_str());
        qDebug() << "adblocker" << adb;
        Q_EMIT adblockInitialized();
        return adb;
    });
#endif
}

inline const char *resource_type_to_string(const QWebEngineUrlRequestInfo::ResourceType type)
{
    // Strings from https://docs.rs/crate/adblock/0.3.3/source/src/request.rs
    using Type = QWebEngineUrlRequestInfo::ResourceType;
    switch(type) {
    case Type::ResourceTypeMainFrame:
        return "main_frame";
    case Type::ResourceTypeSubFrame:
        return "sub_frame";
    case Type::ResourceTypeStylesheet:
        return "stylesheet";
    case Type::ResourceTypeScript:
        return "script";
    case Type::ResourceTypeFontResource:
        return "font";
    case Type::ResourceTypeImage:
        return "image";
    case Type::ResourceTypeSubResource:
        return "object_subrequest"; // TODO CHECK
    case Type::ResourceTypeObject:
        return "object";
    case Type::ResourceTypeMedia:
        return "media";
    case Type::ResourceTypeFavicon:
        return "image"; // almost
    case Type::ResourceTypeXhr:
        return "xhr";
    case Type::ResourceTypePing:
        return "ping";
    case Type::ResourceTypeCspReport:
        return "csp_report";
    default:
        return "other";
    }
}

void AdblockUrlInterceptor::interceptRequest(QWebEngineUrlRequestInfo &info)
{
#ifdef BUILD_ADBLOCK
    if (!m_enabled) {
        return;
    }

    // Only wait for the adblock initialization if it isn't ready on first use
    if (!m_adblock) {
        qDebug() << "Adblock not yet initialized, blindly allowing request";
        return;
    }

    const std::string url = info.requestUrl().toString().toStdString();
    const std::string firstPartyUrl = info.firstPartyUrl().toString().toStdString();
    AdblockResult *result = should_block(m_adblock, url.c_str(), firstPartyUrl.c_str(), resource_type_to_string(info.resourceType()));

    if (result->redirect != nullptr) {
        info.redirect(QUrl(QString::fromUtf8(result->redirect)));
    } else {
        info.block(result->matched);
    }

    free_adblock_result(result);
#else
    Q_UNUSED(info);
#endif
}

void q_cdebug_adblock(const char *message)
{
    qCDebug(AdblockCategory) << message;
}