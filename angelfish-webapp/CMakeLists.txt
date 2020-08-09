set(angelfish_webapp_SRCS
    main.cpp
    ../src/browsermanager.cpp
    ../src/bookmarkshistorymodel.cpp
    ../src/dbmanager.cpp
    ../src/iconimageprovider.cpp
    ../src/sqlquerymodel.cpp
    ../src/urlutils.cpp
    ../src/urlobserver.cpp
    ../src/useragent.cpp
    ../src/tabsmodel.cpp
    ../src/settingshelper.cpp
    webapp-resources.qrc
    ../src/resources.qrc
)

add_executable(angelfish-webapp ${angelfish_webapp_SRCS} ${RESOURCES} ${WEBAPP_RESOURCES})

kconfig_add_kcfg_files(angelfish-webapp GENERATE_MOC ../src/angelfishsettings.kcfgc)

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
    KF5::ConfigCore
    KF5::ConfigGui
)

install(TARGETS angelfish-webapp ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})

