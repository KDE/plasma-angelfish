# SPDX-FileCopyrightText: 2020 2020 Jonah Brüchert
# SPDX-FileCopyrightText: 2020 2020 Jonah Brüchert <jbb@kaidan.im>
# SPDX-FileCopyrightText: 2020 2020 Rinigus <rinigus.git@gmail.com>
#
# SPDX-License-Identifier: LGPL-2.0-or-later

set(angelfish_webapp_SRCS
    main.cpp
    webapp-resources.qrc
)

add_executable(angelfish-webapp ${angelfish_webapp_SRCS} ${RESOURCES} ${WEBAPP_RESOURCES})

target_include_directories(angelfish-webapp PRIVATE ../src/)
target_compile_definitions(angelfish-webapp PRIVATE -DQT_NO_CAST_FROM_ASCII)
target_link_libraries(angelfish-webapp
    Qt5::Core
    Qt5::Qml
    Qt5::Quick
    Qt5::Sql
    Qt5::Svg
    Qt5::WebEngine
    KF5::I18n
    KF5::CoreAddons
    AngelfishCore
)

install(TARGETS angelfish-webapp ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})

