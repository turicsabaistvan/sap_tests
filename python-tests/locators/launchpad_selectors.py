"""
Selectors for the SAP Fiori launchpad shell header and profile menu.
"""


class LaunchpadSelectors:
    ME_AREA_BUTTON = "#meAreaHeaderButton"
    USER_ACTIONS_BUTTON = "#userActionsMenuHeaderButton"
    # The sign out entry carries a generated id whose suffix is stable.
    SIGN_OUT_ITEM = '[id$="logoutBtn"]'
    SIGN_OUT_ITEM_TEXT = 'text="Sign Out"'
    SIGN_OUT_CONFIRM_BUTTON = "#__mbox-btn-0"
