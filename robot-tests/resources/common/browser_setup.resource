*** Settings ***
Documentation    Browser session keywords for the Fiori launchpad suite.

Library          Browser
Resource         common_variables.resource


*** Keywords ***
Open Browser To Fiori Url
    [Documentation]    Opens a fresh browser context and navigates to the Fiori launchpad URL.
    [Arguments]    ${url}=${BASE_URL}
    Validate Configuration
    New Browser    ${BROWSER_TYPE}    headless=${HEADLESS_MODE}
    ${record_size}=    Evaluate    {'width': $VIEWPORT_WIDTH, 'height': $VIEWPORT_HEIGHT}
    ${video}=    Evaluate    {'dir': $VIDEO_RECORDING_DIR, 'size': $record_size} if $VIDEO_RECORDING_DIR else None
    New Context
    ...    viewport={'width': ${VIEWPORT_WIDTH}, 'height': ${VIEWPORT_HEIGHT}}
    ...    locale=${BROWSER_LOCALE}
    ...    recordVideo=${video}
    New Page    ${url}

Close Browser Session
    [Documentation]    Closes every browser session opened by the suite, if any.
    Run Keyword And Ignore Error    Close Browser    ALL

Validate Configuration
    [Documentation]    Fails fast with a clear message when any required environment variable is missing or empty.
    ${missing}=    Evaluate    [name for name in $REQUIRED_ENV_VARIABLES if not os.getenv(name)]    modules=os
    IF    $missing
        Fail    Required environment variables are missing or empty: ${missing}
    END
