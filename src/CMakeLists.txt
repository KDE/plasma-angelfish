set(angelfish_SRCS
    main.cpp
    browsermanager.cpp
    bookmarkshistorymodel.cpp
    dbmanager.cpp
    iconimageprovider.cpp
    sqlquerymodel.cpp
    urlutils.cpp
    useragent.cpp
    urlobserver.cpp
    tabsmodel.cpp
    desktopfilegenerator.cpp
    settingshelper.cpp
)

qt5_add_resources(RESOURCES resources.qrc)

add_executable(angelfish ${angelfish_SRCS} ${RESOURCES})

kconfig_add_kcfg_files(angelfish GENERATE_MOC angelfishsettings.kcfgc)

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
)

install(TARGETS angelfish ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES angelfishsettings.kcfg DESTINATION ${KCFG_INSTALL_DIR})
