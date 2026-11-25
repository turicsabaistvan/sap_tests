# pytest + Playwright Suite

This suite tests the SAP Fiori trial subaccount lifecycle with pytest and Playwright for Python. It follows the Page Object Model and shares the Fiori trial account and test data with the other lifecycle implementations.

> **Account safety:** The suite deletes and recreates the configured subaccount (default: `Tester`). Use a dedicated trial account and do not run this suite concurrently with the Robot, Playwright Test, Jenkins, or GitHub Actions lifecycle tests.

## Requirements

- Python 3.10+ (Python 3.12 recommended)
- `venv` and `pip`
- A Fiori trial account

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
export FIORI_USERNAME="you@example.com"
export FIORI_PASSWORD="secret"
export BASE_URL="https://account.hanatrial.ondemand.com/"
```

`FIORI_USERNAME` and `FIORI_PASSWORD` are required. Shared test-data variables include `SUBACCOUNT_NAME`, `SUBACCOUNT_DESCRIPTION`, `SUBACCOUNT_REGION`, `DISPLAY_TEXT_REPEAT`, and `DESC_TEXT_REPEAT`; their defaults are listed in the [general README](../README.md#shared-fiori-configuration). Never commit `.env` or real credentials.

## Run tests

Run the Fiori-marked tests:

```bash
pytest -m fiori
```

The suite modifies the Fiori account during a full run. Do not run it alongside another suite or workflow using the same account.

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
- **Report or artifact paths are missing:** confirm that the test run completed far enough to produce the report; screenshots and traces are generated on failure.
- **Another run is modifying the subaccount:** wait for all other local and CI lifecycle runs to finish before retrying.

For shared configuration, Docker/Jenkins, GitHub Actions, and repository-wide safety notes, see the [general README](../README.md).
