# Playwright Test Suite

This suite implements the SAP Fiori trial subaccount lifecycle with Playwright Test and TypeScript. It follows the Page Object Model and exercises the same workflow as the other Fiori lifecycle suites.

> **Account safety:** The tests delete and recreate the configured subaccount (default: `Tester`). Use a dedicated Fiori trial account. Do not run this suite concurrently with the Robot, pytest, Jenkins, or GitHub Actions lifecycle tests against the same account.

## Requirements

- Node.js 22 LTS or 24 LTS
- npm
- A Fiori trial account

## Installation

```bash
cd playwright-test
npm ci
npx playwright install --with-deps chromium
```

To install multiple browsers, replace `chromium` with the browser projects you intend to run (for example `chromium firefox webkit`). On Windows, omit `--with-deps`:

```powershell
npx playwright install chromium
```

## Configuration

The suite loads a local `.env` file from `playwright-test/` when present. Alternatively, set the variables in the shell:

```bash
export FIORI_USERNAME="you@example.com"
export FIORI_PASSWORD="secret"
export BASE_URL="https://account.hanatrial.ondemand.com/"
```

`FIORI_USERNAME` and `FIORI_PASSWORD` are required. Shared test-data variables include `SUBACCOUNT_NAME`, `SUBACCOUNT_DESCRIPTION`, `SUBACCOUNT_REGION`, `DISPLAY_TEXT_REPEAT`, and `DESC_TEXT_REPEAT`; their defaults are documented in the [general README](../README.md#shared-fiori-configuration). Never commit `.env` or real credentials.

## Run tests

Run the Chromium project:

```bash
npx playwright test --project=chromium
npx playwright show-report
```

Run all projects configured by the suite:

```bash
npx playwright test
```

The configuration defines Chromium, Firefox, and WebKit projects and uses a single worker because the Fiori trial account is shared. The browser locale is pinned to `hu-HU` to keep the Hungarian login selectors deterministic.

## Checks and reports

```bash
npm run typecheck
npm run lint
```

The HTML report is produced by Playwright and can be opened with `npx playwright show-report`. Jenkins and GitHub Actions also retain reports and failure artifacts; see the [repository CI guide](../README.md#ci-and-docker).

## Troubleshooting

- **`npm ci` fails:** keep `package-lock.json` in sync with `package.json`; after dependency changes, run `npm install` and commit the updated lockfile.
- **`browserType.launch: Executable doesn't exist`:** install the browser for the project being run with `npx playwright install chromium` (or the corresponding browser).
- **Credentials are missing:** verify that `playwright-test/.env` exists and contains the required values, or export them in the shell.
- **Another run is modifying the subaccount:** wait for the other local or CI run to finish before starting this suite.

For shared environment variables, Docker/Jenkins, GitHub Actions, and account safety guidance, see the [general README](../README.md).
