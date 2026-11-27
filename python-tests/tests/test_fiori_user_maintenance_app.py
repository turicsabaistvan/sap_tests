"""
User Maintenance app journey on the SAP Fiori launchpad.

Opens the User Maintenance app from the All My Apps view in a new tab,
searches in its user name input help, then closes the tab, verifies the
launchpad home page again and signs out. Login is a precondition. The test
changes no business data: it only searches in an input help and cancels the
dialogs.
"""

import pytest

from pages.all_my_apps_page import AllMyAppsPage
from pages.launchpad_page import LaunchpadPage
from pages.login_page import LoginPage
from pages.session import login_with_configured_user, logout_from_fiori

# Catalog that contains the app, the app title and the client the launchpad
# must remain on after the app tab is closed.
APP_CATALOG = "Z_TEST_CAT"
APP_NAME = "User Maintenance"
EXPECTED_CLIENT = "800"


@pytest.mark.fiori
@pytest.mark.e2e
def test_open_user_maintenance_and_check_user_name_input_help(
    login_page: LoginPage,
    launchpad_page: LaunchpadPage,
    all_my_apps_page: AllMyAppsPage,
    base_url: str,
    fiori_language: str,
    credentials: dict[str, str],
) -> None:
    """Runs the whole journey and ends with a sign out."""
    # 1. Assert the launchpad home page on the configured client.
    login_with_configured_user(
        login_page,
        launchpad_page,
        base_url,
        fiori_language,
        credentials,
    )
    launchpad_page.assert_home_page_is_intact(EXPECTED_CLIENT, base_url)

    # 2. Open Home - Show All My Apps and select the Z_TEST_CAT catalog.
    all_my_apps_page.open_all_my_apps()
    all_my_apps_page.select_data_source(APP_CATALOG)

    # 3. Start User Maintenance in a new tab and assert its initial screen.
    user_maintenance_page = all_my_apps_page.open_app_in_new_tab(APP_NAME)
    user_maintenance_page.assert_app_is_open()

    # 4. Fill the configured user name, search in the input help and check
    #    that it returns users, then cancel the dialog.
    user_maintenance_page.fill_user_name(credentials["username"])
    user_maintenance_page.open_user_name_input_help()
    user_maintenance_page.close_input_help()

    # 5. Close the app tab and assert the launchpad home page again.
    user_maintenance_page.close_app()
    launchpad_page.bring_to_front()
    launchpad_page.assert_home_page_is_intact(EXPECTED_CLIENT, base_url)

    # 6. Sign out and wait for the logon page.
    logout_from_fiori(launchpad_page, login_page)
