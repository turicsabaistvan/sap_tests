# Robot Framework + Browser Tests

This suite automates the SAP Fiori trial subaccount lifecycle using Robot Framework and the Browser library (Playwright). It is a browser-based suite and is separate from the Windows SAP GUI Scripting suite in [`sap_gui_tests/`](../sap_gui_tests/README.md).

The test journey includes an empty-password validation, cookie handling, conditional deletion of the configured test subaccount, subaccount creation with region selection, long-text editing, and restoration of default values.

> **Account safety:** The suite deletes and recreates the configured subaccount (default: `Tester`). Use a dedicated Fiori trial account and do not run this suite at the same time as the Playwright, pytest, Jenkins, or GitHub Actions lifecycle tests.

## Requirements

- Python 3.10+ (Python 3.12 recommended)
- Node.js 22.15+ (Node.js 24 LTS recommended)
- A Fiori trial account and access to the target landing page

## Installation

From this directory, create a virtual environment and install the dependencies:

```bash
python -m venv .venv
source .venv/bin/activate                  # Windows PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
rfbrowser init                             # Linux may use: rfbrowser init --with-deps
```

On Windows, install the Chromium browser with the Browser library initialization command; `--with-deps` is intended for Linux environments.

## Configuration

Robot reads settings from the process environment. Configure the required credentials and, optionally, the test URL and browser:

```bash
export FIORI_USERNAME="you@example.com"
export FIORI_PASSWORD="secret"
export BASE_URL="https://account.hanatrial.ondemand.com/"
export BROWSER="chromium"
export HEADLESS="true"
```

PowerShell:

```powershell
$env:FIORI_USERNAME = "you@example.com"
$env:FIORI_PASSWORD = "secret"
$env:BASE_URL = "https://account.hanatrial.ondemand.com/"
$env:BROWSER = "chromium"
$env:HEADLESS = "true"
```

The lifecycle test data can be overridden with `SUBACCOUNT_NAME`, `SUBACCOUNT_DESCRIPTION`, `SUBACCOUNT_REGION`, `DISPLAY_TEXT_REPEAT`, and `DESC_TEXT_REPEAT`. Their defaults are `Tester`, `Test`, `US East (VA) - AWS`, `15`, and `10`, respectively. Keep real credentials out of the repository.

## Run the suite

Run from `robot-tests/`:

```bash
robot --outputdir results tests/
```

To check that the suite parses without opening a browser or changing the account:

```bash
robot --dryrun tests/
```

The full run requires a working Fiori account and modifies its subaccount data.

## Reports

Robot writes its results to `results/`:

- `results/report.html` — summary report
- `results/log.html` — detailed keyword log
- `results/output.xml` — machine-readable results

Jenkins and GitHub Actions also retain the suite's CI reports and failure artifacts; see the [repository CI guide](../README.md#ci-and-docker).

## Troubleshooting

- **Missing Fiori credentials:** set `FIORI_USERNAME` and `FIORI_PASSWORD` in the process environment before running Robot.
- **Browser executable is missing:** run `rfbrowser init` in this virtual environment; on Linux, initialize with required system dependencies as appropriate.
- **Robot cannot resolve resource files:** run `robot --outputdir results tests/` from `robot-tests/` and preserve the suite's `resources/` directory.
- **A run was interrupted during deletion:** do not start another lifecycle suite until the Fiori account has recovered; a cancelled deletion may leave the subaccount in a “Deletion in Progress” state.

For shared configuration, Jenkins/GitHub Actions usage, and repository-wide safety notes, see the [general README](../README.md).
