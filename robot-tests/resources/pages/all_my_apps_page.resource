*** Settings ***
Documentation    Page object for the launchpad Home - Show All My Apps view.

Library          Browser
Resource         ../common/common_variables.resource
Resource         ../selectors/all_my_apps_selectors.resource
Resource         launchpad_page.resource


*** Keywords ***
Open All My Apps
    [Documentation]    Opens the All My Apps list from the launchpad header and waits for its data sources.
    Wait For Elements State    ${ALL_MY_APPS_BUTTON}    visible    timeout=${LAUNCHPAD_TIMEOUT}
    Click    ${ALL_MY_APPS_BUTTON}
    Wait For Elements State    ${ALL_MY_APPS_DATA_SOURCES}    visible    timeout=${LAUNCHPAD_TIMEOUT}

Select App Data Source
    [Documentation]    Selects the given catalog in the All My Apps data source list.
    [Arguments]    ${catalog}
    Wait For Elements State    ${ALL_MY_APPS_DATA_SOURCE_ITEM}:has-text("${catalog}")    visible
    ...    timeout=${LAUNCHPAD_TIMEOUT}
    ...    message=The All My Apps view has no data source titled "${catalog}".
    Click    ${ALL_MY_APPS_DATA_SOURCE_ITEM}:has-text("${catalog}")

Open App In New Tab
    [Documentation]    Clicks the given app option and switches to the tab the app opens in.
    [Arguments]    ${app_name}
    ${promise}=    Promise To    Switch Page    NEW
    ${option}=    Get Element By Role    option    name=${app_name}    exact=${True}
    Wait For Elements State    ${option}    visible    timeout=${LAUNCHPAD_TIMEOUT}
    ...    message=The All My Apps view has no application titled "${app_name}".
    Click    ${option}
    Wait For    ${promise}

Return To Launchpad Home Page
    [Documentation]    Closes the active app tab and waits for the launchpad home page again.
    Close Page
    Wait For Elements State    ${LAUNCHPAD_DASHBOARD_GROUPS}    visible    timeout=${LAUNCHPAD_TIMEOUT}
