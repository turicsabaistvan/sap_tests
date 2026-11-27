*** Settings ***
Documentation     Smoke test for the Fiori launchpad logon flow.
...
...               Opens BASE_URL, sets the language on the logon page, signs in with the
...               FIORI_USERNAME / FIORI_PASSWORD credentials and signs out again.

Library           Browser
Resource          ../../resources/common/common_variables.resource
Resource          ../../resources/common/browser_setup.resource
Resource          ../../resources/common/session.resource
Resource          ../../resources/pages/login_page.resource
Resource          ../../resources/pages/launchpad_page.resource

Suite Setup       Open Browser To Fiori Url
Suite Teardown    Close Browser Session
Test Teardown     Run Keyword If Test Failed    Run Keyword And Ignore Error    Take Screenshot    fullPage=True


*** Test Cases ***
Login With Configured Language And Log Out
    [Documentation]    Logs on to the Fiori launchpad, sets the logon language and signs out.
    [Tags]    fiori    login    smoke
    Log In To Fiori Launchpad
    Log Out From Launchpad
    Assert Logon Page Is Displayed
