"""
Page Object for the SAP Fiori launchpad shell.
"""

from playwright.sync_api import Page
from playwright.sync_api import (
    TimeoutError as PlaywrightTimeoutError,
)

from locators.launchpad_selectors import LaunchpadSelectors
from locators.login_selectors import LoginSelectors
from pages.base_page import BasePage


class LaunchpadPage(BasePage):
    LAUNCHPAD_TIMEOUT_MS = 60_000

    def __init__(self, page: Page) -> None:
        super().__init__(page)

    def wait_for_launchpad(self) -> None:
        # The profile head item is created disabled and only enabled once the
        # shell has finished loading, so "enabled" is the readiness signal.
        try:
            self.wait_for_enabled(
                LaunchpadSelectors.ME_AREA_BUTTON, self.LAUNCHPAD_TIMEOUT_MS
            )
        except (PlaywrightTimeoutError, AssertionError):
            self.report_login_error_if_displayed()
            raise AssertionError(
                "The Fiori launchpad did not load within "
                f"{self.LAUNCHPAD_TIMEOUT_MS // 1000} seconds."
            ) from None

    def report_login_error_if_displayed(self) -> None:
        if not self.is_visible(LoginSelectors.ERROR_BLOCK, 2_000):
            return
        message = self.page.locator(LoginSelectors.ERROR_BLOCK).inner_text()
        raise AssertionError(f"Login failed: {message.strip()}")

    def logout(self) -> None:
        self.open_user_actions_menu()
        self.open_sign_out_action()
        self.confirm_sign_out_if_requested()
        self.wait_for_visible(
            LoginSelectors.USERNAME_INPUT, self.LAUNCHPAD_TIMEOUT_MS
        )

    def open_user_actions_menu(self) -> None:
        if self.is_visible(LaunchpadSelectors.ME_AREA_BUTTON, 5_000):
            self.click(LaunchpadSelectors.ME_AREA_BUTTON)
            return
        self.click(
            LaunchpadSelectors.USER_ACTIONS_BUTTON, self.LONG_TIMEOUT_MS
        )

    def open_sign_out_action(self) -> None:
        if self.is_visible(
            LaunchpadSelectors.SIGN_OUT_ITEM, self.DEFAULT_TIMEOUT_MS
        ):
            self.click(LaunchpadSelectors.SIGN_OUT_ITEM)
            return
        self.click(LaunchpadSelectors.SIGN_OUT_ITEM_TEXT)

    def confirm_sign_out_if_requested(self) -> None:
        if self.is_visible(
            LaunchpadSelectors.SIGN_OUT_CONFIRM_BUTTON, 5_000
        ):
            self.click(LaunchpadSelectors.SIGN_OUT_CONFIRM_BUTTON)

    def assert_home_page_is_intact(
        self, expected_client: str, base_url: str
    ) -> None:
        """Asserts the home page is loaded on the expected client."""
        self.wait_for_visible(
            LaunchpadSelectors.DASHBOARD_GROUPS, self.LAUNCHPAD_TIMEOUT_MS
        )
        self.assert_no_visible_elements(
            LaunchpadSelectors.MESSAGE_BOX,
            "The launchpad home page shows an error dialog.",
        )
        # SAP stores the client in the session after logon, so the loaded URL
        # no longer carries it.
        if f"sap-client={expected_client}" not in base_url:
            raise AssertionError(
                "The configured BASE_URL does not target client "
                f"{expected_client}."
            )
        current_url = self.page.url
        base_path = base_url.split("#")[0].split("?")[0]
        current_path = current_url.split("#")[0].split("?")[0]
        if current_path != base_path:
            raise AssertionError(
                "The launchpad navigated away from the configured URL "
                f"(current url: {current_url})."
            )
        if "#Shell-home" not in current_url:
            raise AssertionError(
                "The launchpad did not return to the home page."
            )
