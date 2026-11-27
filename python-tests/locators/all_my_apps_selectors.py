"""
Selectors for the launchpad Home - Show All My Apps view.

The sapUshell* ids are internal launchpad markup, not a public API. They are
verified against the target system and must be re-checked when the launchpad
release differs.
"""


class AllMyAppsSelectors:
    # Header button that opens the All My Apps list.
    ALL_MY_APPS_BUTTON = 'role=button[name="Home - Show All My Apps"]'

    # Data source (catalog) list on the left of the All My Apps view.
    DATA_SOURCES_LIST = "#sapUshellAllMyAppsDataSourcesList"
    DATA_SOURCE_ITEM = (
        '[id*="sapUshellAllMyAppsDataSourcesList"][id$="-content"]'
    )
