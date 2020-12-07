add_library(AngelfishCore STATIC
    browsermanager.cpp
    bookmarkshistorymodel.cpp
    dbmanager.cpp
    iconimageprovider.cpp
    sqlquerymodel.cpp
    urlutils.cpp
    urlobserver.cpp
    useragent.cpp
    tabsmodel.cpp
    settingshelper.cpp
    angelfishwebprofile.cpp
    downloadmanager.cpp
    resources.qrc
)

kconfig_add_kcfg_files(AngelfishCore GENERATE_MOC angelfishsettings.kcfgc)

target_include_directories(AngelfishCore PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_definitions(AngelfishCore PRIVATE -DQT_NO_CAST_FROM_ASCII)
target_link_libraries(AngelfishCore PUBLIC
    Qt5::Core
    Qt5::Sql
    Qt5::WebEngine
    KF5::ConfigCore
    KF5::ConfigGui
    KF5::I18n
    KF5::Notifications
)

install(FILES angelfishsettings.kcfg DESTINATION ${KCFG_INSTALL_DIR})
