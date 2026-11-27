"""
Pytest fixtures: browser, context, page, and page objects.

Credentials are read from environment variables (populated by .env locally
and by Jenkins Credentials Store in CI).
"""

import os
from collections.abc import Iterator
from pathlib import Path
from typing import Any

import pytest
from dotenv import load_dotenv
from playwright.sync_api import Browser, BrowserContext, Page, sync_playwright

from pages.all_my_apps_page import AllMyAppsPage
from pages.launchpad_page import LaunchpadPage
from pages.login_page import LoginPage

load_dotenv()

RESULTS_DIR = Path("test-results")
VIDEO_DIR = RESULTS_DIR / "videos"
VIDEO_SIZE = {"width": 1280, "height": 720}


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(
    item: pytest.Item, call: pytest.CallInfo
) -> Iterator[None]:
    """Expose the test report on the item so fixtures can detect failures."""
    outcome = yield
    report = outcome.get_result()  # type: ignore[attr-defined]
    setattr(item, f"rep_{report.when}", report)


@pytest.fixture(scope="session")
def browser() -> Iterator[Browser]:
    headless = os.getenv("HEADLESS", "true").lower() == "true"
    browser_name = os.getenv("BROWSER", "chromium")
    with sync_playwright() as p:
        browser = getattr(p, browser_name).launch(headless=headless)
        yield browser
        browser.close()


@pytest.fixture(scope="function")
def context(browser: Browser) -> Iterator[BrowserContext]:
    options: dict[str, Any] = {
        "viewport": {"width": 1920, "height": 1080},
        "locale": os.getenv("BROWSER_LOCALE", "en-US"),
    }
    # A demo recording keeps the videos of the passing run; regular runs do
    # not record. Playwright writes one video per page into the directory.
    if os.getenv("RECORD_VIDEO", "").lower() == "on":
        VIDEO_DIR.mkdir(parents=True, exist_ok=True)
        options["record_video_dir"] = str(VIDEO_DIR)
        options["record_video_size"] = VIDEO_SIZE

    context = browser.new_context(**options)
    yield context
    context.close()


@pytest.fixture(scope="function")
def page(
    context: BrowserContext, request: pytest.FixtureRequest
) -> Iterator[Page]:
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    page = context.new_page()
    context.tracing.start(screenshots=True, snapshots=True)
    yield page

    rep_call = getattr(request.node, "rep_call", None)
    failed = bool(rep_call is not None and rep_call.failed)
    safe_name = request.node.name.replace("/", "_").replace("\\", "_")

    try:
        if failed:
            try:
                page.screenshot(
                    path=str(RESULTS_DIR / f"{safe_name}.png"),
                    full_page=True,
                )
            finally:
                context.tracing.stop(
                    path=str(RESULTS_DIR / f"{safe_name}-trace.zip")
                )
        else:
            context.tracing.stop()
    finally:
        page.close()


@pytest.fixture(scope="function")
def login_page(page: Page) -> LoginPage:
    return LoginPage(page)


@pytest.fixture(scope="function")
def launchpad_page(page: Page) -> LaunchpadPage:
    return LaunchpadPage(page)


@pytest.fixture(scope="function")
def all_my_apps_page(page: Page) -> AllMyAppsPage:
    return AllMyAppsPage(page)


@pytest.fixture(scope="session")
def base_url() -> str:
    return os.getenv("BASE_URL", "https://account.hanatrial.ondemand.com/")


@pytest.fixture(scope="session")
def fiori_language() -> str:
    return os.getenv("FIORI_LANGUAGE", "EN")


@pytest.fixture(scope="session")
def credentials() -> dict[str, str]:
    username = os.getenv("FIORI_USERNAME", "")
    password = os.getenv("FIORI_PASSWORD", "")
    if not username or not password:
        pytest.fail(
            "FIORI_USERNAME and FIORI_PASSWORD environment variables "
            "must be set.",
            pytrace=False,
        )
    return {"username": username, "password": password}
