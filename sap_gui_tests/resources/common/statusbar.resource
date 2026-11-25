*** Settings ***
Documentation       Status bar verification keywords shared by page objects.

Library             ${CURDIR}/../../SapComLibrary.py


*** Keywords ***
Statusbar Should Not Report Error
    [Documentation]    Fails when the SAP status bar shows an error (type E).
    ${status_type}=    Get Statusbar Type
    Should Not Be Equal As Strings    ${status_type}    E
    ...    msg=SAP status bar error: '${status_type}'.
