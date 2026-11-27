*** Settings ***
Documentation    Locators for the User Maintenance app opened from the launchpad.
...
...              The ids and titles come from the SAP GUI for HTML rendering of the app and are
...              verified against the target system.


*** Variables ***
${USER_MAINTENANCE_USER_NAME_INPUT}       css=input[title^="User Name in User Master"]
${USER_MAINTENANCE_INPUT_HELP_BUTTON}     css=#ls-inputfieldhelpbutton
${USER_MAINTENANCE_INPUT_HELP_DIALOG}     css=#SearchHelp1
${USER_MAINTENANCE_INPUT_HELP_FIND}       css=[title="Find"]:visible
${USER_MAINTENANCE_INPUT_HELP_CANCEL}     css=[title="Cancel"]:visible
