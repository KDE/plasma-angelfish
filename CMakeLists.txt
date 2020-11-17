# SPDX-FileCopyrightText: 2020 2014-2015 Sebastian Kügler <sebas@kde.org>
# SPDX-FileCopyrightText: 2020 2020 Jonah Brüchert <jbb@kaidan.im>
#
# SPDX-License-Identifier: LGPL-2.0-or-later

project(angelfish)

cmake_minimum_required(VERSION 2.8.12)
set(KF5_MIN_VERSION "5.62.0")
set(QT_MIN_VERSION "5.14.0")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_TESTING "Build test programs" ON)

################# Disallow in-source build #################

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "This application requires an out of source build. Please create a separate build directory.")
endif()

include(FeatureSummary)

################# set KDE specific information #################

find_package(ECM 5.64.0 REQUIRED NO_MODULE)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDEClangFormat)
include(ECMPoQmTools)
include(KDECompilerSettings NO_POLICY_SCOPE)

################# Find dependencies #################

find_package(Qt5 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui Svg QuickControls2 Sql)
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS Kirigami2 Purpose I18n Config CoreAddons DBusAddons WindowSystem)

# Necessary to support QtWebEngine installed in a different prefix than the rest of Qt (e.g flatpak)
find_package(Qt5WebEngine REQUIRED)

# For adblocker
find_package(Corrosion)
set_package_properties(Corrosion PROPERTIES
    PURPOSE "Required to build the builtin adblocker"
)

################# Definitions to pass to the compiler #################

add_definitions(-DQT_NO_FOREACH)
kde_enable_exceptions()

################# build and install #################
add_subdirectory(lib)
add_subdirectory(src)
if (BUILD_TESTING)
    add_subdirectory(autotests)
endif()
add_subdirectory(angelfish-webapp)

install(PROGRAMS org.kde.mobile.angelfish.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.mobile.angelfish.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES org.kde.mobile.angelfish.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES src/*.cpp src/*.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
