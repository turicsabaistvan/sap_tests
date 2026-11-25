*** Settings ***
Documentation       Page object for transaction SE16N (General Table Display).

Library             ${CURDIR}/../../SapComLibrary.py
Resource            ../common/statusbar.resource


*** Variables ***
${SE16N_TABLE_FIELD}                wnd[0]/usr/ctxtGD-TAB
${SE16N_TABLE_DESCRIPTION_FIELD}    wnd[0]/usr/txtGD_TABL_TEXT
${SE16N_NUMBER_OF_HITS_FIELD}       wnd[0]/usr/txtGD-NUMBER
${SE16N_RESULT_GRID}                wnd[0]/usr/cntlRESULT_LIST/shellcont/shell
${SE16N_TITLE}                      wnd[0]/titl
${SE16N_EXECUTE_VKEY}               8


*** Keywords ***
Open Table In SE16N
    [Documentation]    Opens the SE16N initial screen and enters the table name.
    [Arguments]    ${table_name}
    Run Transaction    /nSE16N
    Input Text    ${SE16N_TABLE_FIELD}    ${table_name}
    Send Vkey    0
    Acknowledge Warnings And Popups
    Statusbar Should Not Report Error

SE16N Table Should Be Displayed
    [Documentation]    Verifies the table name and description shown by SE16N.
    [Arguments]    ${table_name}    ${table_description}
    ${shown_table}=    Get Text    ${SE16N_TABLE_FIELD}
    Should Be Equal As Strings    ${shown_table}    ${table_name}
    ${description}=    Get Text    ${SE16N_TABLE_DESCRIPTION_FIELD}
    Should Be Equal As Strings    ${description}    ${table_description}

SE16N Result Title Should Contain
    [Documentation]    Verifies the result screen belongs to the expected table.
    [Arguments]    ${table_name}
    ${title}=    Get Text    ${SE16N_TITLE}
    Should Contain    ${title}    ${table_name}

Execute SE16N Selection
    [Documentation]    Executes the current selection (F8) and dismisses popups.
    Send Vkey    ${SE16N_EXECUTE_VKEY}
    Acknowledge Warnings And Popups
    Statusbar Should Not Report Error

Get SE16N Number Of Hits
    [Documentation]    Returns the hit count reported on the SE16N result screen.
    ${hits}=    Get Text    ${SE16N_NUMBER_OF_HITS_FIELD}
    ${value}=    Convert To Integer    ${hits}
    RETURN    ${value}

SE16N Result Grid Should Have Rows
    [Documentation]    Verifies that the ALV result grid contains at least one row.
    ${rows}=    Grid Row Count    ${SE16N_RESULT_GRID}
    Should Be True    ${rows} > 0    msg=The SE16N result grid is empty.

SE16N Table Should Contain Data
    [Documentation]    Opens a table in SE16N and verifies that data is displayed.
    [Arguments]    ${table_name}    ${table_description}
    Open Table In SE16N    ${table_name}
    SE16N Table Should Be Displayed    ${table_name}    ${table_description}
    Execute SE16N Selection
    SE16N Result Title Should Contain    ${table_name}
    ${hits}=    Get SE16N Number Of Hits
    Should Be True    ${hits} > 0    msg=SE16N returned no rows for table ${table_name}.
    SE16N Result Grid Should Have Rows
