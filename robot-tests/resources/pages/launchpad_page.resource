*** Settings ***
Documentation    Page object for the SAP Fiori launchpad shell.

Library          Browser
Resource         ../common/common_variables.resource
Resource         ../selectors/launchpad_page_selectors.resource
Resource         ../selectors/login_page_selectors.resource


*** Keywords ***
Wait For Fiori Launchpad
    [Documentation]    Waits for the launchpad profile button and reports a rejected login clearly.
    ${loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LAUNCHPAD_ME_AREA_BUTTON}    visible    timeout=${LAUNCHPAD_TIMEOUT}
    IF    ${loaded}
        ${loaded}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${LAUNCHPAD_ME_AREA_BUTTON}    enabled    timeout=${LONG_TIMEOUT}
    END
    IF    not ${loaded}
        Report Login Error If Displayed
        ${url}=    Get Url
        Fail    The Fiori launchpad did not load within ${LAUNCHPAD_TIMEOUT} (url: ${url}).
    END

Report Login Error If Displayed
    [Documentation]    Fails with the logon page error message when the credentials were rejected.
    ${error_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LOGIN_ERROR_BLOCK}    visible    timeout=2s
    IF    ${error_visible}
        ${error_text}=    Get Text    ${LOGIN_ERROR_BLOCK}
        Fail    Login failed: ${error_text}
    END

Log Out From Launchpad
    [Documentation]    Signs out through the profile menu and waits for the logon page again.
    Open User Actions Menu
    Open Sign Out Action
    Confirm Sign Out If Requested
    Wait For Elements State    ${LOGIN_USERNAME_INPUT}    visible    timeout=${LAUNCHPAD_TIMEOUT}

Open User Actions Menu
    [Documentation]    Opens the profile menu, supporting both launchpad header variants.
    ${me_area_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LAUNCHPAD_ME_AREA_BUTTON}    visible    timeout=5s
    IF    ${me_area_visible}
        Click    ${LAUNCHPAD_ME_AREA_BUTTON}
    ELSE
        Wait For Elements State    ${LAUNCHPAD_USER_ACTIONS_BUTTON}    visible    timeout=${LONG_TIMEOUT}
        Click    ${LAUNCHPAD_USER_ACTIONS_BUTTON}
    END

Open Sign Out Action
    [Documentation]    Clicks the Sign Out entry of the profile menu.
    ${sign_out_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${SIGN_OUT_MENU_ITEM}    visible    timeout=${DEFAULT_TIMEOUT}
    IF    ${sign_out_visible}
        Click    ${SIGN_OUT_MENU_ITEM}
    ELSE
        Wait For Elements State    ${SIGN_OUT_MENU_ITEM_TEXT}    visible    timeout=${DEFAULT_TIMEOUT}
        Click    ${SIGN_OUT_MENU_ITEM_TEXT}
    END

Confirm Sign Out If Requested
    [Documentation]    Clicks the confirmation button when the launchpad shows a sign out dialog.
    ${confirm_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${SIGN_OUT_CONFIRM_BUTTON}    visible    timeout=5s
    IF    ${confirm_visible}    Click    ${SIGN_OUT_CONFIRM_BUTTON}

Assert Launchpad Home Page Is Intact
    [Documentation]    Asserts the configured URL targets the expected client and the loaded home page
    ...    shows no error dialog and was not reached through a redirect.
    [Arguments]    ${expected_client}
    Wait For Elements State    ${LAUNCHPAD_DASHBOARD_GROUPS}    visible    timeout=${LAUNCHPAD_TIMEOUT}
    ${error_count}=    Get Element Count    ${LAUNCHPAD_MESSAGE_BOX}
    Should Be Equal As Integers    ${error_count}    0    The launchpad home page shows an error dialog.
    # SAP stores the client in the session after logon, so the loaded URL no longer carries it.
    Should Contain    ${BASE_URL}    sap-client=${expected_client}
    ...    The configured BASE_URL does not target client ${expected_client}.
    ${current}=    Get Url
    ${base_path}=    Evaluate    $BASE_URL.split('#')[0].split('?')[0]
    ${current_path}=    Evaluate    $current.split('#')[0].split('?')[0]
    Should Be Equal    ${current_path}    ${base_path}
    ...    The launchpad navigated away from the configured URL (current url: ${current}).
    Should Contain    ${current}    \#Shell-home    The launchpad did not return to the home page.
