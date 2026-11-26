# Robot Framework Fiori Login/Logout Tests

This suite contains a single smoke test for the SAP Fiori launchpad: it opens the configured `BASE_URL`, sets the language on the logon page, signs in with the configured credentials and signs out again. It does not change any business data.

The suite uses Robot Framework with the Browser library (Playwright).

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

Run the static analysis (Robocop 9 uses the `check` subcommand):

```bash
robocop check resources tests
```

## Reports

Robot writes its results to `results/`:

- `results/report.html` — summary report
- `results/log.html` — detailed keyword log, including a screenshot when the test fails
- `results/output.xml` — machine-readable results

## Troubleshooting

- **Missing configuration:** provide `FIORI_USERNAME`, `FIORI_PASSWORD`, `BASE_URL`, `BROWSER`, `HEADLESS` and `FIORI_LANGUAGE` in the repository-root `.env` or in the environment. The suite aborts before opening a browser and reports the missing or empty variable names.
- **Browser executable is missing:** run `rfbrowser init` in this virtual environment.
- **The logon page has no language drop-down:** the SAP system might not offer language selection on the logon page; the test expects the `#LANGUAGE_SELECT` control and fails if it is absent.
- **Sign out fails:** the profile menu markup differs between SAPUI5 releases. The suite opens `#meAreaHeaderButton` (falling back to `#userActionsMenuHeaderButton`) and clicks the `Sign Out` entry by its `logoutBtn` id suffix or its text; adjust the selectors in `resources/selectors/launchpad_page_selectors.resource` if the launchpad uses another variant.
- **Unexpected logon error:** the failure message contains the text of the logon page error block when the launchpad does not load.

For shared configuration and the repository CI setup, see the [general README](../README.md).
