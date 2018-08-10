project(plasma-angelfish)

cmake_minimum_required(VERSION 2.8.12)

################# Disallow in-source build #################

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "angelfish requires an out of source build. Please create a separate build directory and run 'cmake path_to_plasma-mobile [options]' there.")
endif()

include(CPack)
include(FeatureSummary)
find_package(PkgConfig)

################# set KDE specific information #################

find_package(ECM 0.0.8 REQUIRED NO_MODULE)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui)

################# Enable C++11 features for clang and gcc #################

if(UNIX)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++0x")
endif()

################# now find all used packages #################

set (QT_MIN_VERSION "5.4.0")

find_package(Qt5WebEngine CONFIG)
set_package_properties(Qt5WebEngine PROPERTIES
                       TYPE OPTIONAL
                      )
add_feature_info("Qt5WebEngine" Qt5WebEngine_FOUND "Required for building the Angelfish webbrowser")

find_package(KF5 REQUIRED COMPONENTS
                KIO Plasma Declarative I18n Kirigami2)
#########################################################################



if(Qt5WebEngine_FOUND)

    add_subdirectory(src)
    add_subdirectory(autotests)

    install( PROGRAMS angelfish.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} )

    plasma_install_package(package org.kde.plasma.satellite.angelfish packages package)
    #install(FILES plasma-mobile-browser.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

endif()
