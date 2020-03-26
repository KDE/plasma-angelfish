set(angelfish_SRCS
    main.cpp
    browsermanager.cpp
    bookmarkshistorymodel.cpp
    dbmanager.cpp
    iconimageprovider.cpp
    sqlquerymodel.cpp
    urlutils.cpp
    useragent.cpp
    tabsmodel.cpp
)

qt5_add_resources(RESOURCES resources.qrc)

add_executable(angelfish ${angelfish_SRCS} ${RESOURCES})
target_link_libraries(angelfish Qt5::Core Qt5::Qml Qt5::Quick Qt5::Sql Qt5::Svg Qt5::WebEngine KF5::I18n)

install(TARGETS angelfish ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})

set(angelfish_webapp_SRCS
    webappmain.cpp
    browsermanager.cpp
    bookmarkshistorymodel.cpp
    dbmanager.cpp
    iconimageprovider.cpp
    sqlquerymodel.cpp
    urlutils.cpp
    useragent.cpp
    tabsmodel.cpp
)

qt5_add_resources(WEBAPP_RESOURCES webapp-resources.qrc)

add_executable(angelfish-webapp ${angelfish_webapp_SRCS} ${RESOURCES} ${WEBAPP_RESOURCES})
target_link_libraries(angelfish-webapp Qt5::Core Qt5::Qml Qt5::Quick Qt5::Sql Qt5::Svg Qt5::WebEngine KF5::I18n)

install(TARGETS angelfish-webapp ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
