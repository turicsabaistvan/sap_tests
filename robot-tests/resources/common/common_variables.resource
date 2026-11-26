*** Settings ***
Documentation    Shared variables for the Fiori launchpad login/logout suite.
# Loads the repository .env before the %{...} variables below are resolved.
Library          env_loader.py


*** Variables ***
# Environment variables are mandatory: Robot stops before the suite starts when
# one of them is undefined, and empty values are rejected by Validate Configuration.
@{REQUIRED_ENV_VARIABLES}
...    FIORI_USERNAME    FIORI_PASSWORD    BASE_URL    BROWSER
...    HEADLESS    FIORI_LANGUAGE

# Credentials must be provided via FIORI_USERNAME / FIORI_PASSWORD.
${BASE_URL}             %{BASE_URL}
${BROWSER_TYPE}         %{BROWSER}
${HEADLESS_MODE}        %{HEADLESS}
# SAP language code selected in the logon page language drop-down.
${FIORI_LANGUAGE}       %{FIORI_LANGUAGE}

# Browser locale is fixed; the SAP logon language is selected explicitly instead.
${BROWSER_LOCALE}       en-US

${VIEWPORT_WIDTH}       1920
${VIEWPORT_HEIGHT}      1080
${DEFAULT_TIMEOUT}      10s
${LONG_TIMEOUT}         30s
${LAUNCHPAD_TIMEOUT}    60s

# The password is never stored in a variable; login reads %FIORI_PASSWORD directly.
${USERNAME}             %{FIORI_USERNAME}
