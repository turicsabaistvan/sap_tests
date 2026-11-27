*** Settings ***
Documentation     Opens a Fiori app from the launchpad All My Apps view and checks its input help.
...
...               Login is a precondition: the suite opens BASE_URL (client 800 is part of the
...               configured URL) and signs in with the configured credentials. The test opens
...               the User Maintenance app from catalog Z_TEST_CAT in a new tab, checks the user
...               name input help, then closes the tab and verifies the launchpad home page again.

Library           Browser
Resource          ../../resources/common/common_variables.resource
Resource          ../../resources/common/session.resource
Resource          ../../resources/pages/launchpad_page.resource
Resource          ../../resources/pages/all_my_apps_page.resource
Resource          ../../resources/pages/user_maintenance_page.resource

Suite Setup       Open Browser And Log In To Fiori
Suite Teardown    Close Browser Session
Test Teardown     Run Keyword If Test Failed    Run Keyword And Ignore Error    Take Screenshot    fullPage=True


*** Variables ***
${EXPECTED_CLIENT}      800
${APP_CATALOG}          Z_TEST_CAT
${APP_NAME}             User Maintenance
# The input help is exercised with the configured Fiori user, never with a hardcoded name.
${USER_TO_CHECK}        ${USERNAME}


*** Test Cases ***
Open User Maintenance From All My Apps
    [Documentation]    Opens the User Maintenance app from the Z_TEST_CAT catalog in a new tab,
    ...    checks the User Name input help, then closes the tab and verifies the home page.
    [Tags]    fiori    launchpad    app
    Assert Launchpad Home Page Is Intact    ${EXPECTED_CLIENT}
    Open All My Apps
    Select App Data Source    ${APP_CATALOG}
    Open App In New Tab    ${APP_NAME}
    Assert User Maintenance App Is Open
    Check User Name Input Help    ${USER_TO_CHECK}
    Return To Launchpad Home Page
    Assert Launchpad Home Page Is Intact    ${EXPECTED_CLIENT}
