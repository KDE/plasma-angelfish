include(ECMAddTests)

find_package(Qt5 ${REQUIRED_QT_VERSION} CONFIG REQUIRED Test)

include_directories(../src)

ecm_add_test(urlmodeltest.cpp ../src/urlmodel.cpp
             TEST_NAME urlmodeltest
             LINK_LIBRARIES Qt5::Test
)

ecm_add_test(useragenttest.cpp ../src/useragent.cpp
             TEST_NAME useragenttest
             LINK_LIBRARIES Qt5::Test
)

ecm_add_test(browsermanagertest.cpp ../src/browsermanager.cpp ../src/urlmodel.cpp ../src/urlutils.cpp
             TEST_NAME browsermanagertest
             LINK_LIBRARIES Qt5::Test
)

ecm_add_test(tabsmodeltest.cpp ../src/tabsmodel.cpp ../src/browsermanager.cpp ../src/urlmodel.cpp
             TEST_NAME tabsmodeltest
             LINK_LIBRARIES Qt5::Test
)
