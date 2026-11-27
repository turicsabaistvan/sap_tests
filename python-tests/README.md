# pytest + Playwright Fiori Login/Logout and App Tests

This suite contains two tests for the SAP Fiori launchpad: a login/logout smoke test and a User Maintenance app journey. Both open the configured `BASE_URL`, set the language on the logon page, sign in with the configured credentials and sign out again; the app journey additionally opens the All My Apps view, starts the User Maintenance app in a new tab, searches in its user name input help and closes the tab. Neither test changes business data.

It uses pytest with Playwright for Python and follows the Page Object Model.

## Requirements

- Python 3.10+ (Python 3.12 recommended)
- `venv` and `pip`
- A Fiori launchpad user with logon permissions

## Installation

```bash
cd python-tests
python -m venv .venv
source .venv/bin/activate                  # Windows PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements-dev.txt
playwright install chromium
```

## Configuration

The suite loads a `.env` file when present, starting in `python-tests/` and falling back to the repository root. Alternatively, configure the environment variables in the shell:

```bash
export FIORI_USERNAME="your-user"
export FIORI_PASSWORD="secret"
export BASE_URL="http://fiori-host:8000/sap/bc/ui5_ui5/ui2/ushell/shells/abap/FioriLaunchpad.html#Shell-home"
export FIORI_LANGUAGE="EN"
export BROWSER="chromium"
export HEADLESS="true"
```

| Variable | Required | Description |
|---|---|---|
| `FIORI_USERNAME` | yes | Fiori user name (`sap-user`) |
| `FIORI_PASSWORD` | yes | Fiori password; it is never written to the report |
| `BASE_URL` | yes | Fiori launchpad logon URL |
| `FIORI_LANGUAGE` | no | SAP language code selected on the logon page; default `EN` |
| `BROWSER` | no | Browser engine: `chromium`, `firefox` or `webkit`; default `chromium` |
| `HEADLESS` | no | Run the browser headless; default `true` |
| `BROWSER_LOCALE` | no | Browser locale used before the language is selected; default `en-US` |
| `RECORD_VIDEO` | no | Set to `on` to record the browser into `test-results/videos/` (used only to produce the README demo); default is no recording |

Keep real credentials out of the repository.

## Run tests

```bash
pytest -m fiori
```

Run only the app journey:

```bash
pytest tests/test_fiori_user_maintenance_app.py -m fiori
```

Check that pytest collects the suite without opening a browser:

```bash
pytest --collect-only
```

## App launch suite

The app journey test runs the whole flow and ends with a sign out:

1. Assert the launchpad home page on the configured client (`800`) without an error dialog.
2. Open **Home - Show All My Apps** in the launchpad header and select the `Z_TEST_CAT` catalog.
3. Start the **User Maintenance** app, which opens in a new tab, and assert its initial screen.
4. Fill the *User Name in User Master* field with the configured Fiori user
   (`FIORI_USERNAME`), open the field's input help, press **Find** and check that the search
   returns users.
5. Cancel the input help, close the app tab and assert that the launchpad home page is back on
   the configured client without an error dialog or redirect.
6. Sign out from the launchpad profile menu and wait for the logon page.

The test changes no business data: it only searches in an input help and cancels the dialogs.
The test data is defined as constants at the top of the test module:

| Constant | Value | Description |
|---|---|---|
| `APP_CATALOG` | `Z_TEST_CAT` | Catalog in the All My Apps data source list that contains the app. |
| `APP_NAME` | `User Maintenance` | App title clicked in the All My Apps view. |
| `EXPECTED_CLIENT` | `800` | SAP client that must remain in the home page URL after the app is closed. |

The user name comes from `FIORI_USERNAME`; no user name is hardcoded. All locators live in
`locators/`. The launchpad and app markup is release-specific: if the target system uses another
UI5 release, adjust `all_my_apps_selectors.py`, `user_maintenance_selectors.py` and
`launchpad_selectors.py`.

## Checks and reports

```bash
ruff check .
mypy
```

The HTML report is written to `reports/report.html`. On failure, a full-page screenshot and Playwright trace are written to `test-results/`.

Jenkins and GitHub Actions also retain reports and failure artifacts; see the [repository CI guide](../README.md#ci-and-docker).

## Test run video

The recording below was made during a live run of `test_fiori_user_maintenance_app.py` against the
test system and shows the whole journey: logon, the **Home - Show All My Apps** view, the
**User Maintenance** app in a new tab, filling the user name and searching in its input help (with
the result list), closing the app tab, and the sign out back to the logon page.

[![Test run video preview](docs/video/test-run-preview.gif)](docs/video/test-run.mp4)

*The animated GIF is a 2× speed preview. Click it to open the full, real-time recording:
[`docs/video/test-run.mp4`](docs/video/test-run.mp4) (15 seconds).*

To record a run yourself, set `RECORD_VIDEO=on`:

```bash
RECORD_VIDEO=on pytest tests/test_fiori_user_maintenance_app.py -m fiori
```

The videos are written to `test-results/videos/` and kept even when the run passes. Playwright
records one video per page — the launchpad page and the app tab separately — so the example video
uses the launchpad recording up to the moment the app opens, then the full app tab recording, then
the launchpad recording again from the point where the app tab is closed through the sign out.

## Troubleshooting

- **`browserType.launch: Executable doesn't exist`:** install Chromium from this virtual environment with `playwright install chromium`.
- **Credentials are missing:** verify `python-tests/.env` or the repository-root `.env`, or export `FIORI_USERNAME` and `FIORI_PASSWORD` in the shell.
- **The logon page has no language drop-down:** the SAP system might not offer language selection on the logon page; the test expects the `#LANGUAGE_SELECT` control and fails if it is absent.
- **Sign out fails:** the profile menu markup differs between SAPUI5 releases. The page object opens `#meAreaHeaderButton` (falling back to `#userActionsMenuHeaderButton`) and clicks the `Sign Out` entry by its `logoutBtn` id suffix or its text; adjust `locators/launchpad_selectors.py` if the launchpad uses another variant.
- **The app is not found in All My Apps:** check `APP_CATALOG` and `APP_NAME`; the app option is matched by its exact accessible name.
- **The input help search finds no users:** the test fills `FIORI_USERNAME` and presses **Find**; the result rows exist but are scrolled out of view, so the test asserts their count, not their visibility.
- **The first Cancel is ignored:** SAP processes the search after the first click, so the page object retries Cancel for 30 seconds in 2-second intervals.
- **The app journey times out:** the SU01 search and the new-tab transition are slow on some systems; the page objects use explicit 60/30-second waits.
- **No video for a passing run:** record with `RECORD_VIDEO=on`; Playwright writes one video per page into `test-results/videos/`.
- **Unexpected logon error:** the failure message contains the text of the logon page error block when the launchpad does not load.
- **Report or artifact paths are missing:** confirm that the test run completed far enough to produce the report; screenshots and traces are generated on failure.

For shared configuration, Docker/Jenkins, GitHub Actions, and repository-wide notes, see the [general README](../README.md).
