*** Settings ***
Documentation       Shared keywords for starting and stopping the SAP GUI session.

Library             Process
Library             ${CURDIR}/../../SapComLibrary.py


*** Keywords ***
Open SAP Session
    [Documentation]    Starts SAP GUI via sapshcut and attaches to the new session.
    Wait Until Keyword Succeeds    2x    5s    Start And Attach SAP Session
    Acknowledge Warnings And Popups
    Element Should Be Present    wnd[0]/tbar[0]/okcd

Start And Attach SAP Session
    [Documentation]    Starts a fresh SAP GUI process and attaches to its session.
    Kill Existing SAP Processes
    Start Process    ${SAPSHCUT_EXE}
    ...    -guiparm\=/H/${SAP_APP_SERVER}/S/32${SAP_SYS_NUM}
    ...    -system\=${SAP_SYS_ID}
    ...    -client\=${SAP_CLIENT}
    ...    -user\=${SAP_USER}
    ...    -pw\=${SAP_PASS}
    ...    -language\=${SAP_LANG}
    Connect To Active Session    timeout=30

Close SAP Session
    [Documentation]    Logs off from SAP and terminates the SAP GUI processes.
    Run Keyword And Ignore Error    Run Transaction    /nex
    Run Keyword And Ignore Error    Kill Existing SAP Processes

Return To SAP Easy Access
    [Documentation]    Navigates back to the SAP Easy Access start screen.
    Run Transaction    /nS000
    Acknowledge Warnings And Popups

SAP Easy Access Should Be Displayed
    [Documentation]    Verifies that the SAP Easy Access start screen is shown.
    ${title}=    Get Text    wnd[0]/titl
    Should Contain    ${title}    SAP Easy Access
