# Playwright Fiori Login/Logout Tests

This suite contains a single smoke test for the SAP Fiori launchpad: it opens the configured `BASE_URL`, sets the language on the logon page, signs in with the configured credentials and signs out again. It does not change any business data.

It uses Playwright Test with TypeScript and follows the Page Object Model.

## Requirements

- Node.js 22 LTS or 24 LTS
- npm
- A Fiori launchpad user with logon permissions

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
export FIORI_USERNAME="your-user"
export FIORI_PASSWORD="secret"
export BASE_URL="http://fiori-host:8000/sap/bc/ui5_ui5/ui2/ushell/shells/abap/FioriLaunchpad.html#Shell-home"
export FIORI_LANGUAGE="EN"
export BROWSER_LOCALE="en-US"
```

| Variable | Required | Description |
|---|---|---|
| `FIORI_USERNAME` | yes | Fiori user name (`sap-user`) |
| `FIORI_PASSWORD` | yes | Fiori password; Playwright masks it in traces and reports |
| `BASE_URL` | yes | Fiori launchpad logon URL |
| `FIORI_LANGUAGE` | no | SAP language code selected on the logon page; default `EN` |
| `BROWSER_LOCALE` | no | Browser locale used before the language is selected; default `en-US` |

Keep real credentials out of the repository. The browser is selected with Playwright's `--project` option, not an environment variable.

## Run tests

```bash
npx playwright test --project=chromium
npx playwright show-report
```

List the collected tests without opening a browser:

```bash
npx playwright test --list
```

Run all projects configured by the suite:

```bash
npx playwright test
```

The configuration defines Chromium, Firefox, and WebKit projects and uses a single worker because the suite signs in and out of the same SAP system.

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
- **The logon page has no language drop-down:** the SAP system might not offer language selection on the logon page; the test expects the `#LANGUAGE_SELECT` control and fails if it is absent.
- **Sign out fails:** the profile menu markup differs between SAPUI5 releases. The page object opens `#meAreaHeaderButton` (falling back to `#userActionsMenuHeaderButton`) and clicks the `Sign Out` entry by its `logoutBtn` id suffix or its text; adjust `selectors/launchpad.selectors.ts` if the launchpad uses another variant.
- **Unexpected logon error:** the failure message contains the text of the logon page error block when the launchpad does not load.

For shared environment variables, Docker/Jenkins, GitHub Actions, and repository-wide notes, see the [general README](../README.md).
