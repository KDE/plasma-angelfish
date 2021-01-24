// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QWebEngineUrlRequestInterceptor>
class QWebEngineUrlRequestInfo;
class QQuickWebEngineProfile;

#ifdef BUILD_ADBLOCK
#include <adblock.rs.h>
#include <optional>
#endif

#include <future>

class AdblockUrlInterceptor : public QWebEngineUrlRequestInterceptor
{
    Q_OBJECT

    Q_PROPERTY(bool downloadNeeded READ downloadNeeded NOTIFY downloadNeededChanged)
#ifdef BUILD_ADBLOCK
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
#endif
    Q_PROPERTY(bool adblockSupported READ adblockSupported CONSTANT)

public:
    static AdblockUrlInterceptor &instance();

    void interceptRequest(QWebEngineUrlRequestInfo &info) override;

    /// returns true when no filterlists exist
    bool downloadNeeded() const;
    Q_SIGNAL void downloadNeededChanged();

    /// Deletes the old adblock and creates a new one from the current filter lists.
    /// This needs to be called after lists were changed.
    void resetAdblock();
    Q_SIGNAL void adblockInitialized();

    Q_SIGNAL void enabledChanged();

    constexpr static bool adblockSupported()
    {
#ifdef BUILD_ADBLOCK
        return true;
#endif
        return false;
    }

#ifdef BUILD_ADBLOCK
    bool enabled() const;
    void setEnabled(bool enabled);
#endif

private:
    explicit AdblockUrlInterceptor(QObject *parent = nullptr);
#ifdef BUILD_ADBLOCK
    rust::Box<Adblock> createAdblock();

    std::future<rust::Box<Adblock>> m_adblockInitFuture;
    std::optional<rust::Box<Adblock>> m_adblock;
    bool m_enabled;
#endif
};

extern "C" {
void q_cdebug_adblock(const char *message);
}
