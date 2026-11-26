*** Settings ***
Documentation    Page object for the SAP Fiori logon page.

Library          Browser
Resource         ../common/common_variables.resource
Resource         ../selectors/login_page_selectors.resource


*** Keywords ***
Assert Logon Page Is Displayed
    [Documentation]    Waits until the Fiori logon form and the user name field are visible.
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${LONG_TIMEOUT}
    Wait For Elements State    ${LOGIN_USERNAME_INPUT}    visible    timeout=${LONG_TIMEOUT}

Set Login Language
    [Documentation]    Selects the logon page language from the Language drop-down.
    [Arguments]    ${language}=${FIORI_LANGUAGE}
    Wait For Elements State    ${LOGIN_LANGUAGE_SELECT}    visible    timeout=${LONG_TIMEOUT}
    # The drop-down is filled by the page script, so retry until the option exists.
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    0.5s
    ...    Select Options By    ${LOGIN_LANGUAGE_SELECT}    value    ${language}
    ${selected}=    Get Selected Options    ${LOGIN_LANGUAGE_SELECT}    value
    Should Contain    ${selected}    ${language}

Fill Username Field
    [Documentation]    Types the user name into the logon form.
    [Arguments]    ${username}
    Wait For Elements State    ${LOGIN_USERNAME_INPUT}    visible    timeout=${DEFAULT_TIMEOUT}
    Fill Text    ${LOGIN_USERNAME_INPUT}    ${username}

Fill Password Field
    [Documentation]    Types the password from FIORI_PASSWORD without writing it to the log.
    Wait For Elements State    ${LOGIN_PASSWORD_INPUT}    visible    timeout=${DEFAULT_TIMEOUT}
    Fill Secret    ${LOGIN_PASSWORD_INPUT}    %FIORI_PASSWORD

Submit Login
    [Documentation]    Submits the logon form.
    Wait For Elements State    ${LOGIN_SUBMIT_BUTTON}    enabled    timeout=${DEFAULT_TIMEOUT}
    Click    ${LOGIN_SUBMIT_BUTTON}
