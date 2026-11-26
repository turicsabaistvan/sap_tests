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

Robot loads the repository-root `.env` file automatically when it exists (via `resources/common/env_loader.py`). Variables set in the process environment always take precedence, which is how CI and Jenkins provide credentials. Set the variables in the shell when no `.env` file is available:

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
| `FIORI_LANGUAGE` | no | SAP language code selected on the logon page; default `EN` |
| `BROWSER` | no | Browser engine: `chromium`, `firefox` or `webkit`; default `chromium` |
| `HEADLESS` | no | Run the browser headless; default `true` |
| `BROWSER_LOCALE` | no | Browser locale used before the language is selected; default `en-US` |

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

- **Missing credentials:** create the repository-root `.env` with `FIORI_USERNAME` and `FIORI_PASSWORD`, or export them before running Robot; the suite fails fast when either is missing.
- **Browser executable is missing:** run `rfbrowser init` in this virtual environment.
- **The logon page has no language drop-down:** the SAP system might not offer language selection on the logon page; the test expects the `#LANGUAGE_SELECT` control and fails if it is absent.
- **Sign out fails:** the profile menu markup differs between SAPUI5 releases. The suite opens `#meAreaHeaderButton` (falling back to `#userActionsMenuHeaderButton`) and clicks the `Sign Out` entry by its `logoutBtn` id suffix or its text; adjust the selectors in `resources/selectors/launchpad_page_selectors.resource` if the launchpad uses another variant.
- **Unexpected logon error:** the failure message contains the text of the logon page error block when the launchpad does not load.

For shared configuration and the repository CI setup, see the [general README](../README.md).
