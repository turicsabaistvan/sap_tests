"""
Base class for all page objects.

Wraps the most common Playwright interactions with sane timeouts so that
page objects stay small and readable.
"""

from playwright.sync_api import (
    Locator,
    Page,
    expect,
)
from playwright.sync_api import (
    TimeoutError as PlaywrightTimeoutError,
)


class BasePage:
    DEFAULT_TIMEOUT_MS = 15_000
    LONG_TIMEOUT_MS = 30_000

    def __init__(self, page: Page) -> None:
        self.page = page

    def _locator(self, selector: str) -> Locator:
        # UI5 often renders duplicate elements (for example several menu
        # entries, plus their destroyed clones). Restrict to visible matches
        # and use the first one like the Robot suite does instead of failing
        # Playwright's strict mode.
        return self.page.locator(selector).filter(visible=True).first

    def wait_for_visible(
        self, selector: str, timeout_ms: int = DEFAULT_TIMEOUT_MS
    ) -> None:
        self._locator(selector).wait_for(state="visible", timeout=timeout_ms)

    def wait_for_enabled(
        self, selector: str, timeout_ms: int = DEFAULT_TIMEOUT_MS
    ) -> None:
        expect(self._locator(selector)).to_be_enabled(timeout=timeout_ms)

    def click(
        self, selector: str, timeout_ms: int = DEFAULT_TIMEOUT_MS
    ) -> None:
        locator = self._locator(selector)
        locator.wait_for(state="visible", timeout=timeout_ms)
        locator.click(timeout=timeout_ms)

    def fill(self, selector: str, value: str) -> None:
        locator = self._locator(selector)
        locator.wait_for(state="visible", timeout=self.DEFAULT_TIMEOUT_MS)
        locator.fill(value)

    def is_visible(self, selector: str, timeout_ms: int = 3_000) -> bool:
        try:
            self._locator(selector).wait_for(
                state="visible", timeout=timeout_ms
            )
            return True
        except PlaywrightTimeoutError:
            return False

    def bring_to_front(self) -> None:
        # Reactivates a background tab, for example the launchpad after an app
        # tab opened on top of it was closed.
        self.page.bring_to_front()

    def assert_no_visible_elements(
        self, selector: str, message: str
    ) -> None:
        expect(self.page.locator(selector), message).to_have_count(0)
