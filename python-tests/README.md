# pytest + Playwright Fiori Login/Logout Tests

This suite contains a single smoke test for the SAP Fiori launchpad: it opens the configured `BASE_URL`, sets the language on the logon page, signs in with the configured credentials and signs out again. It does not change any business data.

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

The suite loads a `.env` file from `python-tests/` when present. Alternatively, configure the environment variables in the shell:

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

Keep real credentials out of the repository.

## Run tests

```bash
pytest -m fiori
```

Check that pytest collects the suite without opening a browser:

```bash
pytest --collect-only
```

## Checks and reports

```bash
ruff check .
mypy
```

The HTML report is written to `reports/report.html`. On failure, a full-page screenshot and Playwright trace are written to `test-results/`.

Jenkins and GitHub Actions also retain reports and failure artifacts; see the [repository CI guide](../README.md#ci-and-docker).

## Troubleshooting

- **`browserType.launch: Executable doesn't exist`:** install Chromium from this virtual environment with `playwright install chromium`.
- **Credentials are missing:** verify `python-tests/.env` or export `FIORI_USERNAME` and `FIORI_PASSWORD` in the shell.
- **The logon page has no language drop-down:** the SAP system might not offer language selection on the logon page; the test expects the `#LANGUAGE_SELECT` control and fails if it is absent.
- **Sign out fails:** the profile menu markup differs between SAPUI5 releases. The page object opens `#meAreaHeaderButton` (falling back to `#userActionsMenuHeaderButton`) and clicks the `Sign Out` entry by its `logoutBtn` id suffix or its text; adjust `locators/launchpad_selectors.py` if the launchpad uses another variant.
- **Unexpected logon error:** the failure message contains the text of the logon page error block when the launchpad does not load.
- **Report or artifact paths are missing:** confirm that the test run completed far enough to produce the report; screenshots and traces are generated on failure.

For shared configuration, Docker/Jenkins, GitHub Actions, and repository-wide notes, see the [general README](../README.md).
