"""
Selectors for the User Maintenance app opened from the launchpad.

The ids and titles come from the SAP GUI for HTML rendering of the app and
are verified against the target system.
"""


class UserMaintenanceSelectors:
    USER_NAME_INPUT = 'input[title^="User Name in User Master"]'
    INPUT_HELP_BUTTON = "#ls-inputfieldhelpbutton"
    INPUT_HELP_DIALOG = "#SearchHelp1"
    INPUT_HELP_FIND = '[title="Find"]:visible'
    INPUT_HELP_CANCEL = '[title="Cancel"]:visible'

    # One cell per hit in the search help result grid.
    INPUT_HELP_RESULTS = "#SHresultgrid1"
    INPUT_HELP_RESULT_ROWS = '#SHresultgrid1-mrss-cont-left td[id^="sh["]'
