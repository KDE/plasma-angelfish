include(ECMAddTests)

find_package(Qt5 ${REQUIRED_QT_VERSION} CONFIG REQUIRED Test Sql Gui Quick)

include_directories(../src)

ecm_add_test(dbmanagertest.cpp ../src/dbmanager.cpp ../src/iconimageprovider.cpp ../src/sqlquerymodel.cpp
             TEST_NAME dbmanagertest
             LINK_LIBRARIES Qt5::Test Qt5::Sql Qt5::Quick
)

ecm_add_test(useragenttest.cpp ../src/useragent.cpp
             TEST_NAME useragenttest
             LINK_LIBRARIES Qt5::Test
)

ecm_add_test(browsermanagertest.cpp ../src/browsermanager.cpp ../src/dbmanager.cpp ../src/iconimageprovider.cpp ../src/urlutils.cpp
             TEST_NAME browsermanagertest
             LINK_LIBRARIES Qt5::Test Qt5::Sql Qt5::Gui Qt5::Quick
)

ecm_add_test(tabsmodeltest.cpp ../src/tabsmodel.cpp ../src/browsermanager.cpp ../src/dbmanager.cpp ../src/iconimageprovider.cpp
             TEST_NAME tabsmodeltest
             LINK_LIBRARIES Qt5::Test Qt5::Sql Qt5::Gui Qt5::Quick
)
