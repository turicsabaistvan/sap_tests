"""
Page Object for the SAP Fiori launchpad logon page.
"""

from playwright.sync_api import Page

from locators.login_selectors import LoginSelectors
from pages.base_page import BasePage


class LoginPage(BasePage):
    def __init__(self, page: Page) -> None:
        super().__init__(page)

    def open(self, url: str) -> None:
        self.page.goto(url, wait_until="domcontentloaded")
        self.wait_for_visible(LoginSelectors.LOGIN_FORM, self.LONG_TIMEOUT_MS)

    def assert_logon_page_is_displayed(self) -> None:
        self.wait_for_visible(
            LoginSelectors.USERNAME_INPUT, self.LONG_TIMEOUT_MS
        )

    def set_language(self, language: str) -> None:
        # The language options are populated by the logon page script, so the
        # <select> is empty in the served HTML.
        self.wait_for_visible(LoginSelectors.LANGUAGE_SELECT)
        self.page.wait_for_function(
            "selector => document.querySelectorAll(selector).length > 0",
            arg=LoginSelectors.LANGUAGE_OPTIONS,
            timeout=self.DEFAULT_TIMEOUT_MS,
        )
        self.page.select_option(
            LoginSelectors.LANGUAGE_SELECT, value=language
        )
        selected = self.page.locator(
            LoginSelectors.LANGUAGE_SELECT
        ).input_value()
        if selected != language:
            raise AssertionError(
                f"Expected logon language {language}, but {selected} was "
                "selected."
            )
        # Selecting a language can reload the logon page in some releases.
        self.assert_logon_page_is_displayed()

    def fill_username(self, username: str) -> None:
        self.fill(LoginSelectors.USERNAME_INPUT, username)

    def fill_password(self, password: str) -> None:
        self.fill(LoginSelectors.PASSWORD_INPUT, password)

    def submit_login(self) -> None:
        self.click(LoginSelectors.SUBMIT_BUTTON)
