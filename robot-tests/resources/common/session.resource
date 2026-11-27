*** Settings ***
Documentation    Reusable session keywords that provide the logged-in launchpad precondition.

Resource         common_variables.resource
Resource         browser_setup.resource
Resource         ../pages/login_page.resource
Resource         ../pages/launchpad_page.resource


*** Keywords ***
Log In To Fiori Launchpad
    [Documentation]    Signs in on the displayed Fiori logon page with the configured credentials.
    Assert Logon Page Is Displayed
    Set Login Language    ${FIORI_LANGUAGE}
    Fill Username Field    ${USERNAME}
    Fill Password Field
    Submit Login
    Wait For Fiori Launchpad

Open Browser And Log In To Fiori
    [Documentation]    Opens BASE_URL in a fresh browser context and signs in to the launchpad.
    Open Browser To Fiori Url
    Log In To Fiori Launchpad
