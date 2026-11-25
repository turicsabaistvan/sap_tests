*** Settings ***
Documentation       Read-only SAP GUI smoke tests: log in, verify Easy Access, read
...                 master data through SE16N, then log off.

Resource            ../resources/common/sap_session.resource
Resource            ../resources/pages/se16n.resource
Variables           ../variables/environment.py

Suite Setup         Open SAP Session
Suite Teardown      Close SAP Session

Test Tags           smoke


*** Test Cases ***
SAP Easy Access Is Displayed After Login
    [Documentation]    The session must land on the SAP Easy Access start screen.
    [Tags]    login
    Return To SAP Easy Access
    SAP Easy Access Should Be Displayed

Read Company Codes From Table T001
    [Documentation]    SE16N must return company-code rows for table T001.
    [Tags]    se16n
    SE16N Table Should Contain Data    T001    Company Codes

Read Clients From Table T000
    [Documentation]    SE16N must return client rows for table T000.
    [Tags]    se16n
    SE16N Table Should Contain Data    T000    Clients

Read Countries From Table T005
    [Documentation]    SE16N must return country rows for table T005.
    [Tags]    se16n
    SE16N Table Should Contain Data    T005    Countries

Read Plants From Table T001W
    [Documentation]    SE16N must return plant rows for table T001W.
    [Tags]    se16n
    SE16N Table Should Contain Data    T001W    Plants/Branches

Read Currency Codes From Table TCURC
    [Documentation]    SE16N must return currency-code rows for table TCURC.
    [Tags]    se16n
    SE16N Table Should Contain Data    TCURC    Currency Codes

Read Units Of Measurement From Table T006
    [Documentation]    SE16N must return unit-of-measure rows for table T006.
    [Tags]    se16n
    SE16N Table Should Contain Data    T006    Units of Measurement

Read Sales Document Types From Table TVAK
    [Documentation]    SE16N must return sales-document-type rows for table TVAK.
    [Tags]    se16n
    SE16N Table Should Contain Data    TVAK    Sales Document Types

Read Sales Organizations From Table TVKO
    [Documentation]    SE16N must return sales-organization rows for table TVKO.
    [Tags]    se16n
    SE16N Table Should Contain Data    TVKO    Organizational Unit: Sales Organizations

Read Distribution Channels From Table TVTW
    [Documentation]    SE16N must return distribution-channel rows for table TVTW.
    [Tags]    se16n
    SE16N Table Should Contain Data    TVTW    Organizational Unit: Distribution Channels

Read Sales Divisions From Table TSPA
    [Documentation]    SE16N must return sales-division rows for table TSPA.
    [Tags]    se16n
    SE16N Table Should Contain Data    TSPA    Organizational Unit: Sales Divisions
