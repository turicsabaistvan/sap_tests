*** Settings ***
Documentation    Page object for the User Maintenance app opened from the launchpad.

Library          Browser
Resource         ../common/common_variables.resource
Resource         ../selectors/launchpad_page_selectors.resource
Resource         ../selectors/user_maintenance_selectors.resource


*** Keywords ***
Assert User Maintenance App Is Open
    [Documentation]    Waits for the app screen and asserts it shows no error dialog.
    Wait For Elements State    ${USER_MAINTENANCE_USER_NAME_INPUT}    visible    timeout=${LAUNCHPAD_TIMEOUT}
    ${error_count}=    Get Element Count    ${LAUNCHPAD_MESSAGE_BOX}
    Should Be Equal As Integers    ${error_count}    0    The User Maintenance app shows an error dialog.

Fill User Name
    [Documentation]    Types the user name into the User Name in User Master field.
    [Arguments]    ${user_name}
    Wait For Elements State    ${USER_MAINTENANCE_USER_NAME_INPUT}    visible    timeout=${LONG_TIMEOUT}
    Fill Text    ${USER_MAINTENANCE_USER_NAME_INPUT}    ${user_name}

Open User Name Input Help
    [Documentation]    Opens the input help of the user name field and searches for the value.
    Click    ${USER_MAINTENANCE_INPUT_HELP_BUTTON}
    Wait For Elements State    ${USER_MAINTENANCE_INPUT_HELP_DIALOG}    visible    timeout=${LAUNCHPAD_TIMEOUT}
    Wait For Elements State    ${USER_MAINTENANCE_INPUT_HELP_FIND}    visible    timeout=${LAUNCHPAD_TIMEOUT}
    Click    ${USER_MAINTENANCE_INPUT_HELP_FIND}

Close Input Help
    [Documentation]    Closes the input help dialog with Cancel and waits until it is gone.
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    2s    Dismiss Input Help Dialog

Dismiss Input Help Dialog
    [Documentation]    Clicks Cancel and waits for the input help dialog to disappear.
    Click    ${USER_MAINTENANCE_INPUT_HELP_CANCEL}
    Wait For Elements State    ${USER_MAINTENANCE_INPUT_HELP_DIALOG}    hidden    timeout=5s

Check User Name Input Help
    [Documentation]    Fills the user name, searches in its input help and closes the dialogs again.
    [Arguments]    ${user_name}
    Fill User Name    ${user_name}
    Open User Name Input Help
    Close Input Help
