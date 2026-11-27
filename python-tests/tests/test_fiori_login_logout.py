"""
Smoke test for the SAP Fiori launchpad logon flow.

Opens BASE_URL, sets the language on the logon page, signs in with the
configured credentials and signs out again. It does not change business data.
"""

import pytest

from pages.launchpad_page import LaunchpadPage
from pages.login_page import LoginPage
from pages.session import login_with_configured_user, logout_from_fiori


@pytest.mark.fiori
@pytest.mark.e2e
def test_login_with_configured_language_and_logout(
    login_page: LoginPage,
    launchpad_page: LaunchpadPage,
    base_url: str,
    fiori_language: str,
    credentials: dict[str, str],
) -> None:
    login_with_configured_user(
        login_page,
        launchpad_page,
        base_url,
        fiori_language,
        credentials,
    )
    logout_from_fiori(launchpad_page, login_page)
