# SPDX-FileCopyrightText: 2020 2020 Jonah Brüchert <jbb@kaidan.im>
# SPDX-FileCopyrightText: 2020 2020 Rinigus <rinigus.git@gmail.com>
#
# SPDX-License-Identifier: LGPL-2.0-or-later

set(angelfish_SRCS
    main.cpp
    desktopfilegenerator.cpp
)

qt5_add_resources(RESOURCES resources.qrc)

add_executable(angelfish ${angelfish_SRCS} ${RESOURCES})

target_include_directories(angelfish PRIVATE)
target_compile_definitions(angelfish PRIVATE -DQT_NO_CAST_FROM_ASCII)
target_link_libraries(angelfish
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
