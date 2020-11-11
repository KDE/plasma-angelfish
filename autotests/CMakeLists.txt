# SPDX-FileCopyrightText: 2020 2020 Jonah Brüchert <jbb@kaidan.im>
# SPDX-FileCopyrightText: 2020 2020 Rinigus <rinigus.git@gmail.com>
#
# SPDX-License-Identifier: LGPL-2.0-or-later

include(ECMAddTests)

find_package(Qt5 ${REQUIRED_QT_VERSION} CONFIG REQUIRED Test Sql Gui Quick)

ecm_add_test(dbmanagertest.cpp
             TEST_NAME dbmanagertest
             LINK_LIBRARIES Qt5::Test Qt5::Sql Qt5::Quick AngelfishCore
)

ecm_add_test(browsermanagertest.cpp
             TEST_NAME browsermanagertest
             LINK_LIBRARIES Qt5::Test Qt5::Sql Qt5::Gui Qt5::Quick AngelfishCore
)

ecm_add_test(tabsmodeltest.cpp
             TEST_NAME tabsmodeltest
             LINK_LIBRARIES Qt5::Test Qt5::Sql Qt5::Gui Qt5::Quick AngelfishCore
)

ecm_add_test(configtest.cpp
             TEST_NAME configtest
             LINK_LIBRARIES Qt5::Test AngelfishCore
)
