*** Settings ***
Documentation    Locators for the SAP Fiori launchpad shell header and profile menu.


*** Variables ***
${LAUNCHPAD_ME_AREA_BUTTON}         css=#meAreaHeaderButton
${LAUNCHPAD_USER_ACTIONS_BUTTON}    css=#userActionsMenuHeaderButton
${SIGN_OUT_MENU_ITEM}               css=[id$="logoutBtn"]:visible
${SIGN_OUT_MENU_ITEM_TEXT}          text="Sign Out"
${SIGN_OUT_CONFIRM_BUTTON}          css=#__mbox-btn-0
${LAUNCHPAD_DASHBOARD_GROUPS}       css=:is(#dashboardGroups, .sapUshellDashboardGroupsContainer)
${LAUNCHPAD_MESSAGE_BOX}            css=.sapMMessageBox:visible
