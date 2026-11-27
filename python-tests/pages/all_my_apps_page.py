"""
Page Object for the launchpad Home - Show All My Apps view.
"""

import json

from playwright.sync_api import expect

from locators.all_my_apps_selectors import AllMyAppsSelectors
from pages.base_page import BasePage
from pages.user_maintenance_page import UserMaintenancePage


class AllMyAppsPage(BasePage):
    VIEW_TIMEOUT_MS = 60_000

    def open_all_my_apps(self) -> None:
        """Opens the All My Apps list and waits for its data sources."""
        self.click(
            AllMyAppsSelectors.ALL_MY_APPS_BUTTON, self.VIEW_TIMEOUT_MS
        )
        self.wait_for_visible(
            AllMyAppsSelectors.DATA_SOURCES_LIST, self.VIEW_TIMEOUT_MS
        )

    def select_data_source(self, catalog: str) -> None:
        """Selects the given catalog in the All My Apps data source list."""
        selector = (
            f"{AllMyAppsSelectors.DATA_SOURCE_ITEM}:has-text("
            f"{json.dumps(catalog)})"
        )
        self.click(selector, self.VIEW_TIMEOUT_MS)

    def open_app_in_new_tab(self, app_name: str) -> UserMaintenancePage:
        """Clicks the given app option and returns the tab it opens in."""
        option = (
            self.page.get_by_role("option", name=app_name, exact=True)
            .filter(visible=True)
            .first
        )
        expect(
            option,
            f'The All My Apps view has no application titled "{app_name}".',
        ).to_be_visible(timeout=self.VIEW_TIMEOUT_MS)

        # Register the popup listener before the click so the new tab cannot
        # be missed.
        with self.page.context.expect_page(
            timeout=self.VIEW_TIMEOUT_MS
        ) as popup_info:
            option.click()

        popup = popup_info.value
        popup.wait_for_load_state("domcontentloaded")
        return UserMaintenancePage(popup)
