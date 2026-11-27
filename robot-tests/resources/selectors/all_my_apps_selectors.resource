*** Settings ***
Documentation    Locators for the launchpad Home - Show All My Apps view.
...
...              The sapUshell* class names and ids are internal launchpad markup, not a public
...              API. They are verified against the target system and must be re-checked if the
...              launchpad release differs.


*** Variables ***
# Header button that opens the All My Apps list.
${ALL_MY_APPS_BUTTON}              role=button[name="Home - Show All My Apps"]

# Data source (catalog) list on the left of the All My Apps view.
${ALL_MY_APPS_DATA_SOURCES}        css=#sapUshellAllMyAppsDataSourcesList
${ALL_MY_APPS_DATA_SOURCE_ITEM}    css=[id*="sapUshellAllMyAppsDataSourcesList"][id$="-content"]
