# SPDX-FileCopyrightText: 2020 2020 Jonah Brüchert <jbb@kaidan.im>
# SPDX-FileCopyrightText: 2020 2020 Rinigus <rinigus.git@gmail.com>
#
# SPDX-License-Identifier: LGPL-2.0-or-later

include(ECMAddTests)

find_package(Qt5 ${REQUIRED_QT_VERSION} CONFIG REQUIRED Test Sql Gui Quick)

include_directories(../src ${CMAKE_CURRENT_BINARY_DIR}/../src/)

set(SETTINGS_SHARED_SRCS ../src/settingshelper.cpp)
kconfig_add_kcfg_files(SETTINGS_SHARED_SRCS GENERATE_MOC ../src/angelfishsettings.kcfgc)

ecm_add_test(dbmanagertest.cpp ../src/dbmanager.cpp ../src/iconimageprovider.cpp ../src/sqlquerymodel.cpp
             ${SETTINGS_SHARED_SRCS}
             TEST_NAME dbmanagertest
             LINK_LIBRARIES Qt5::Test Qt5::Sql Qt5::Quick KF5::ConfigGui
)

ecm_add_test(useragenttest.cpp ../src/useragent.cpp
             TEST_NAME useragenttest
             LINK_LIBRARIES Qt5::Test
)

ecm_add_test(browsermanagertest.cpp ../src/browsermanager.cpp ../src/dbmanager.cpp ../src/iconimageprovider.cpp ../src/urlutils.cpp
             ${SETTINGS_SHARED_SRCS}
             TEST_NAME browsermanagertest
             LINK_LIBRARIES Qt5::Test Qt5::Sql Qt5::Gui Qt5::Quick KF5::ConfigGui
)

ecm_add_test(tabsmodeltest.cpp ../src/tabsmodel.cpp ../src/browsermanager.cpp ../src/dbmanager.cpp ../src/iconimageprovider.cpp
             ${SETTINGS_SHARED_SRCS}
             TEST_NAME tabsmodeltest
             LINK_LIBRARIES Qt5::Test Qt5::Sql Qt5::Gui Qt5::Quick KF5::ConfigGui
)

ecm_add_test(configtest.cpp ${SETTINGS_SHARED_SRCS}
             TEST_NAME configtest
             LINK_LIBRARIES Qt5::Test KF5::ConfigGui
)
