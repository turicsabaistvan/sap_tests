*** Settings ***
Documentation     Opens a Fiori app from the launchpad All My Apps view, searches in its input help
...               and signs out again.
...
...               Login is a precondition: the suite opens BASE_URL (client 800 is part of the
...               configured URL) and signs in with the configured credentials. The test opens
...               the User Maintenance app from catalog Z_TEST_CAT in a new tab, searches for the
...               configured user in the user name input help, then closes the tab, verifies the
...               launchpad home page again and signs out.

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
    [Documentation]    Opens the User Maintenance app from the Z_TEST_CAT catalog, searches in its
    ...    user name input help, closes the app tab and signs out.
    ...    1. Assert the launchpad home page on the configured client.
    ...    2. Open Home - Show All My Apps and select the Z_TEST_CAT catalog.
    ...    3. Start User Maintenance in a new tab and assert its initial screen.
    ...    4. Fill the configured user name, open the input help, press Find and check the results.
    ...    5. Cancel the input help, close the app tab and assert the launchpad home page again.
    ...    6. Sign out and wait for the logon page.
    [Tags]    fiori    launchpad    app
    Assert Launchpad Home Page Is Intact    ${EXPECTED_CLIENT}
    Open All My Apps
    Select App Data Source    ${APP_CATALOG}
    Open App In New Tab    ${APP_NAME}
    Assert User Maintenance App Is Open
    Check User Name Input Help    ${USER_TO_CHECK}
    Return To Launchpad Home Page
    Assert Launchpad Home Page Is Intact    ${EXPECTED_CLIENT}
    Log Out From Fiori Launchpad
