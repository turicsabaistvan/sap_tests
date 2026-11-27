# Robot Framework Fiori Login/Logout Tests

This suite contains two Fiori launchpad tests:

- `fiori_login_logout.robot` opens the configured `BASE_URL`, sets the language on the logon page, signs in with the configured credentials and signs out again.
- `fiori_user_maintenance_app.robot` opens the User Maintenance app from the launchpad All My Apps view in a new tab, searches in the user name input help, then closes the tab, returns to the launchpad and signs out.

Login is a precondition in both suites. Neither test changes business data: the app test only searches in an input help and cancels the dialogs.

The suites use Robot Framework with the Browser library (Playwright).

## Requirements

- Python 3.11+ (Python 3.12 recommended)
- Node.js 22.15+ (Node.js 24 LTS recommended)
- A Fiori launchpad user with logon permissions

## Installation

From this directory, create a virtual environment and install the dependencies:

```bash
python -m venv .venv
source .venv/bin/activate                  # Windows PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
rfbrowser init                            # Linux may use: rfbrowser init --with-deps
```

## Configuration

Robot loads the repository-root `.env` file automatically when it exists (via `resources/common/env_loader.py`). Variables set in the process environment always take precedence, which is how CI and Jenkins provide configuration. All variables below are mandatory and have no fallback values: Robot aborts at suite start when one of them is undefined, and the suite setup rejects empty values, so a misconfigured run never opens a browser.

Set the variables in the shell when no `.env` file is available:

```bash
export FIORI_USERNAME="your-user"
export FIORI_PASSWORD="secret"
export BASE_URL="http://fiori-host:8000/sap/bc/ui5_ui5/ui2/ushell/shells/abap/FioriLaunchpad.html#Shell-home"
export BROWSER="chromium"
export HEADLESS="true"
export FIORI_LANGUAGE="EN"
```

| Variable | Required | Description |
|---|---|---|
| `FIORI_USERNAME` | yes | Fiori user name (`sap-user`) |
| `FIORI_PASSWORD` | yes | Fiori password; it is never written to the Robot log |
| `BASE_URL` | yes | Fiori launchpad logon URL |
| `FIORI_LANGUAGE` | yes | SAP language code selected on the logon page (for example `EN`, `HU`, `DE`) |
| `BROWSER` | yes | Browser engine: `chromium`, `firefox` or `webkit` |
| `HEADLESS` | yes | Run the browser headless: `true` or `false` |

The browser locale is fixed to `en-US`; the SAP language is selected explicitly on the logon page.

Keep real credentials out of the repository.

## Run the suite

Run from `robot-tests/`:

```bash
robot --outputdir results tests/
```

Check that the suite parses without opening a browser:

```bash
robot --dryrun tests/
```

Dry-run also resolves the environment, so the mandatory variables must be available (from `.env` or the shell) for this check to succeed.

## App launch suite

`tests/fiori/fiori_user_maintenance_app.robot` has one test that runs the whole journey and ends
with a sign out:

1. Assert the launchpad home page on the configured client (`800`) without an error dialog.
2. Open **Home - Show All My Apps** in the launchpad header and select the `Z_TEST_CAT` catalog.
3. Start the **User Maintenance** app, which opens in a new tab, and assert its initial screen.
4. Fill the *User Name in User Master* field with the configured Fiori user (`FIORI_USERNAME`),
   open the field's input help, press **Find** and check that the search returns users.
5. Cancel the input help, close the app tab and assert that the launchpad home page is back on
   the configured client without an error dialog or redirect.
6. Sign out from the launchpad profile menu and wait for the logon page.

The test changes no business data: it only searches in an input help and cancels the dialogs.

| Variable | Default | Description |
|---|---|---|
| `${APP_CATALOG}` | `Z_TEST_CAT` | Catalog in the All My Apps data source list that contains the app. |
| `${APP_NAME}` | `User Maintenance` | App title clicked in the All My Apps view. |
| `${EXPECTED_CLIENT}` | `800` | SAP client that must remain in the home page URL after the app is closed. |

The user name comes from `FIORI_USERNAME` (`${USERNAME}`); no user name is hardcoded. Override the test data from the command line with `--variable APP_CATALOG:"<catalog>"` or `--variable APP_NAME:"<app>"`. If the test fails, its teardown takes a full-page screenshot.

All locators are kept in `resources/selectors/`. The launchpad and app markup is release-specific: if the target system uses another UI5 release, adjust `all_my_apps_selectors.resource`, `user_maintenance_selectors.resource` and `launchpad_page_selectors.resource`.

Run the static analysis (Robocop 9 uses the `check` subcommand):

```bash
robocop check resources tests
```

## Reports

Robot writes its results to `results/`:

- `results/report.html` — summary report
- `results/log.html` — detailed keyword log, including a screenshot when the test fails
- `results/output.xml` — machine-readable results

## Test run video

The recording below was made during a live run of `fiori_user_maintenance_app.robot` against the
test system and shows the whole journey: logon, the **Home - Show All My Apps** view, the
**User Maintenance** app in a new tab, filling the user name and searching in its input help (with
the result list), closing the app tab, and the sign out back to the logon page.

[![Test run video preview](docs/video/test-run-preview.gif)](docs/video/test-run.mp4)

*The animated GIF is a 2× speed preview. Click it to open the full, real-time recording:
[`docs/video/test-run.mp4`](docs/video/test-run.mp4) (16 seconds).*

To record a run yourself, set `ROBOT_VIDEO_DIR` to an existing directory. The Browser library then
records one video per page — the launchpad page and every app tab separately:

```bash
ROBOT_VIDEO_DIR=/tmp/fiori-video robot --outputdir results tests/
```

The videos are finalized when the browser closes. The example video uses the launchpad recording
up to the moment the app opens, then the full app tab recording, then again the launchpad recording
from the point where the app tab is closed through the sign out, because the Browser library records
one video per page.

## Troubleshooting

- **Missing configuration:** provide `FIORI_USERNAME`, `FIORI_PASSWORD`, `BASE_URL`, `BROWSER`, `HEADLESS` and `FIORI_LANGUAGE` in the repository-root `.env` or in the environment. The suite aborts before opening a browser and reports the missing or empty variable names.
- **Browser executable is missing:** run `rfbrowser init` in this virtual environment.
- **The logon page has no language drop-down:** the SAP system might not offer language selection on the logon page; the test expects the `#LANGUAGE_SELECT` control and fails if it is absent.
- **Sign out fails:** the profile menu markup differs between SAPUI5 releases. The suite opens `#meAreaHeaderButton` (falling back to `#userActionsMenuHeaderButton`) and clicks the `Sign Out` entry by its `logoutBtn` id suffix or its text; adjust the selectors in `resources/selectors/launchpad_page_selectors.resource` if the launchpad uses another variant.
- **Unexpected logon error:** the failure message contains the text of the logon page error block when the launchpad does not load.

For shared configuration and the repository CI setup, see the [general README](../README.md).
