"""
Page Object for the User Maintenance app opened from the launchpad.
"""

import time

from playwright.sync_api import (
    TimeoutError as PlaywrightTimeoutError,
)
from playwright.sync_api import expect

from locators.launchpad_selectors import LaunchpadSelectors
from locators.user_maintenance_selectors import UserMaintenanceSelectors
from pages.base_page import BasePage


class UserMaintenancePage(BasePage):
    APP_TIMEOUT_MS = 60_000
    SEARCH_TIMEOUT_MS = 30_000

    def assert_app_is_open(self) -> None:
        """Waits for the app screen and asserts it shows no error dialog."""
        self.wait_for_visible(
            UserMaintenanceSelectors.USER_NAME_INPUT, self.APP_TIMEOUT_MS
        )
        self.assert_no_visible_elements(
            LaunchpadSelectors.MESSAGE_BOX,
            "The User Maintenance app shows an error dialog.",
        )

    def fill_user_name(self, user_name: str) -> None:
        """Types the user name into the User Name in User Master field."""
        self.fill(UserMaintenanceSelectors.USER_NAME_INPUT, user_name)

    def open_user_name_input_help(self) -> None:
        """Opens the input help, presses Find and asserts it returns users."""
        self.click(
            UserMaintenanceSelectors.INPUT_HELP_BUTTON, self.APP_TIMEOUT_MS
        )
        self.wait_for_visible(
            UserMaintenanceSelectors.INPUT_HELP_DIALOG, self.APP_TIMEOUT_MS
        )
        self.wait_for_visible(
            UserMaintenanceSelectors.INPUT_HELP_FIND, self.APP_TIMEOUT_MS
        )
        self.click(
            UserMaintenanceSelectors.INPUT_HELP_FIND, self.APP_TIMEOUT_MS
        )
        self.wait_for_visible(
            UserMaintenanceSelectors.INPUT_HELP_RESULTS,
            self.SEARCH_TIMEOUT_MS,
        )
        # The result grid only renders when the search returns hits; its row
        # header cells are scrolled out of the visible area, so the row count
        # is checked instead of their visibility.
        expect(
            self.page.locator(
                UserMaintenanceSelectors.INPUT_HELP_RESULT_ROWS
            ),
            "The user name input help returned no users for the configured "
            "user name.",
        ).not_to_have_count(0, timeout=self.SEARCH_TIMEOUT_MS)

    def close_input_help(self) -> None:
        """Closes the input help with Cancel and waits until it is gone.

        SAP keeps processing the search after the first Cancel click, which
        can swallow it, so the click is retried every two seconds.
        """
        dialog = self.page.locator(UserMaintenanceSelectors.INPUT_HELP_DIALOG)
        deadline = time.monotonic() + self.SEARCH_TIMEOUT_MS / 1000
        while True:
            try:
                if self.is_visible(
                    UserMaintenanceSelectors.INPUT_HELP_CANCEL, 1_000
                ):
                    self.click(
                        UserMaintenanceSelectors.INPUT_HELP_CANCEL, 3_000
                    )
                expect(dialog).to_be_hidden(timeout=5_000)
                return
            except (AssertionError, PlaywrightTimeoutError):
                if time.monotonic() >= deadline:
                    raise AssertionError(
                        "The input help dialog did not close within "
                        f"{self.SEARCH_TIMEOUT_MS // 1000} seconds."
                    ) from None
            self.page.wait_for_timeout(2_000)

    def close_app(self) -> None:
        """Closes the app tab."""
        self.page.close()
