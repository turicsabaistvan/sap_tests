"""
Reusable session steps that provide the logged-in launchpad precondition.
"""

from pages.launchpad_page import LaunchpadPage
from pages.login_page import LoginPage


def login_with_configured_user(
    login_page: LoginPage,
    launchpad_page: LaunchpadPage,
    base_url: str,
    language: str,
    credentials: dict[str, str],
) -> None:
    """Signs in on the Fiori logon page with the configured credentials."""
    login_page.open(base_url)
    login_page.assert_logon_page_is_displayed()
    login_page.set_language(language)
    login_page.fill_username(credentials["username"])
    login_page.fill_password(credentials["password"])
    login_page.submit_login()
    launchpad_page.wait_for_launchpad()


def logout_from_fiori(
    launchpad_page: LaunchpadPage, login_page: LoginPage
) -> None:
    """Signs out from the launchpad and waits for the logon page."""
    launchpad_page.logout()
    login_page.assert_logon_page_is_displayed()
