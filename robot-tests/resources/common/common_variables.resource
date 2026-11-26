*** Settings ***
Documentation    Shared variables for the Fiori launchpad login/logout suite.


*** Variables ***
# Environment variables with sensible defaults.
# Credentials must be provided via FIORI_USERNAME / FIORI_PASSWORD.
${BASE_URL}             %{BASE_URL=https://account.hanatrial.ondemand.com/}
${BROWSER_TYPE}         %{BROWSER=chromium}
${HEADLESS_MODE}        %{HEADLESS=true}
${BROWSER_LOCALE}       %{BROWSER_LOCALE=en-US}
# SAP language code selected in the logon page language drop-down.
${FIORI_LANGUAGE}       %{FIORI_LANGUAGE=EN}

${VIEWPORT_WIDTH}       1920
${VIEWPORT_HEIGHT}      1080
${DEFAULT_TIMEOUT}      10s
${LONG_TIMEOUT}         30s
${LAUNCHPAD_TIMEOUT}    60s

# The password is never stored in a variable; login reads %FIORI_PASSWORD directly.
${USERNAME}             %{FIORI_USERNAME=}
