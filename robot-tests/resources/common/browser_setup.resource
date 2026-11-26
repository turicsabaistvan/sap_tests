*** Settings ***
Documentation    Browser session keywords for the Fiori launchpad suite.

Library          Browser
Resource         common_variables.resource


*** Keywords ***
Open Browser To Fiori Url
    [Documentation]    Opens a fresh browser context and navigates to the Fiori launchpad URL.
    [Arguments]    ${url}=${BASE_URL}
    Validate Credentials
    New Browser    ${BROWSER_TYPE}    headless=${HEADLESS_MODE}
    New Context
    ...    viewport={'width': ${VIEWPORT_WIDTH}, 'height': ${VIEWPORT_HEIGHT}}
    ...    locale=${BROWSER_LOCALE}
    New Page    ${url}

Close Browser Session
    [Documentation]    Closes every browser session opened by the suite.
    Close Browser    ALL

Validate Credentials
    [Documentation]    Fails fast with a clear message when the Fiori credentials are missing.
    ${username_set}=    Evaluate    bool(os.getenv('FIORI_USERNAME'))    modules=os
    ${password_set}=    Evaluate    bool(os.getenv('FIORI_PASSWORD'))    modules=os
    IF    not ${username_set}
        Fail    FIORI_USERNAME environment variable is not set.
    END
    IF    not ${password_set}
        Fail    FIORI_PASSWORD environment variable is not set.
    END
