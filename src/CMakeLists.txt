# SPDX-FileCopyrightText: 2020 2020 Jonah Brüchert <jbb@kaidan.im>
# SPDX-FileCopyrightText: 2020 2020 Rinigus <rinigus.git@gmail.com>
#
# SPDX-License-Identifier: LGPL-2.0-or-later

set(angelfish_SRCS
    main.cpp
    desktopfilegenerator.cpp
    adblockfilterlistsmodel.cpp
    adblockfilterlistsmanager.cpp
    adblockurlinterceptor.cpp
    downloadsmodel.cpp
    angelfish.qrc
)

add_executable(angelfish ${angelfish_SRCS})

if (Corrosion_FOUND)
    add_custom_target(adblock
        SOURCES
        rs/adblock/Cargo.toml
        rs/adblock/build.rs
        rs/adblock/src/lib.rs
        rs/adblock/src/adblock.rs
        rs/adblock/src/domainresolver.rs
        rs/adblock/src/logging.rs)

    corrosion_import_crate(MANIFEST_PATH ${CMAKE_CURRENT_SOURCE_DIR}/rs/adblock/Cargo.toml)
    target_link_libraries(angelfish PRIVATE angelfish-adblock)
    target_compile_definitions(angelfish PRIVATE -DBUILD_ADBLOCK)
else()
    message("warning: Corrosion not found, not building adblocker")
endif()

target_include_directories(angelfish PRIVATE)
target_compile_definitions(angelfish PRIVATE -DQT_NO_CAST_FROM_ASCII)
target_link_libraries(angelfish PRIVATE
    Qt5::Core
    Qt5::Qml
    Qt5::Quick
    Qt5::Sql
    Qt5::Svg
    Qt5::WebEngine
    KF5::I18n
    KF5::ConfigCore
    KF5::ConfigGui
    KF5::DBusAddons
    KF5::WindowSystem
    AngelfishCore
)

install(TARGETS angelfish ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES angelfish.notifyrc DESTINATION ${KNOTIFYRC_INSTALL_DIR})
