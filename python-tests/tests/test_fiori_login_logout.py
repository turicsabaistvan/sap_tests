"""
Smoke test for the SAP Fiori launchpad logon flow.

Opens BASE_URL, sets the language on the logon page, signs in with the
configured credentials and signs out again. It does not change business data.
"""

import pytest

from pages.launchpad_page import LaunchpadPage
from pages.login_page import LoginPage


@pytest.mark.fiori
@pytest.mark.e2e
def test_login_with_configured_language_and_logout(
    login_page: LoginPage,
    launchpad_page: LaunchpadPage,
    base_url: str,
    fiori_language: str,
    credentials: dict[str, str],
) -> None:
    login_page.open(base_url)
    login_page.assert_logon_page_is_displayed()
    login_page.set_language(fiori_language)
    login_page.fill_username(credentials["username"])
    login_page.fill_password(credentials["password"])
    login_page.submit_login()
    launchpad_page.wait_for_launchpad()
    launchpad_page.logout()
    login_page.assert_logon_page_is_displayed()
