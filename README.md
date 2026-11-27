# Fiori Test Automation

This repository contains automated SAP Fiori launchpad tests in three independent frameworks, a separate SAP GUI smoke-test suite, and the CI infrastructure used to run them.

## Test suites

| Suite | Framework | Location | Guide | Scope |
|---|---|---|---|---|
| Fiori — Robot | Robot Framework + Browser (Playwright) | `robot-tests/` | [Robot Framework guide](robot-tests/README.md) | Login/logout smoke test and a read-only User Maintenance app journey |
| Fiori — TypeScript | Playwright Test | `playwright-test/` | [Playwright guide](playwright-test/README.md) | Login/logout smoke test and a read-only User Maintenance app journey |
| Fiori — Python | pytest + Playwright | `python-tests/` | [pytest guide](python-tests/README.md) | Login/logout smoke test and a read-only User Maintenance app journey |
| SAP GUI smoke tests | Robot Framework + SAP GUI Scripting COM | `sap_tests/` | [SAP GUI guide](sap_tests/README.md) | Read-only SE16N table checks on Windows |

The three Fiori suites implement the same flows with independent frameworks: a login/logout smoke test and an app journey that opens the `Z_TEST_CAT` catalog's User Maintenance app from All My Apps in a new tab, searches in its user name input help, closes the tab and signs out. All of them open `BASE_URL`, select the logon language, sign in with the configured credentials, and sign out; none of them change business data. `sap_tests/` is a separate Windows-only suite for SAP GUI for Windows; it does not use the Fiori browser workflow.

> **Important:** The browser suites open a session against the same SAP system, so serializing runs avoids overlapping sessions. They only sign in, browse and sign out, so they do not modify the account. The SAP GUI suite is read-only with respect to business data, but its setup and teardown terminate running SAP GUI processes; save any unsaved SAP work before running it.

## Repository layout

```text
.
├── .github/workflows/       # Manual GitHub Actions workflow
├── .githooks/               # Optional pre-commit checks
├── robot-tests/             # Robot Framework + Browser Fiori login/logout and app journey tests
├── playwright-test/         # Playwright Test / TypeScript Fiori login/logout and app journey tests
├── python-tests/            # pytest + Playwright Fiori login/logout and app journey tests
├── sap_tests/           # Windows SAP GUI Scripting suite
├── compose.yml              # Jenkins and Docker-in-Docker services
├── Dockerfile.jenkins       # Jenkins controller image
├── Dockerfile.robot         # Robot Browser runner image
├── Dockerfile.playwright    # TypeScript Playwright runner image
├── Dockerfile.python-tests  # pytest runner image
├── jenkins.yaml             # Jenkins Configuration as Code
├── plugins.txt              # Pinned Jenkins plugins
└── .env.example             # Local Compose/Jenkins configuration template
```

`python-tests/locators/` is named `locators` rather than `selectors` so it does not shadow Python's standard-library `selectors` module.

## Getting started

The browser-based suites run on Linux or Windows and require Python and/or Node.js as listed in their suite guides. Docker 24+ with Docker Compose v2 is required for the Jenkins/Compose setup. SAP GUI tests require a Windows desktop session with SAP GUI for Windows and SAP GUI Scripting enabled on both client and server; see the [SAP GUI guide](sap_tests/README.md).

### Shared Fiori configuration

Copy the template for the local Jenkins/Compose setup and set the required credentials:

```bash
cp .env.example .env
```

At minimum, configure `FIORI_USERNAME`, `FIORI_PASSWORD`, and (when running Jenkins) `JENKINS_ADMIN_PASSWORD`. Never commit `.env` or real credentials. The Playwright and pytest suites can also load a `.env` file from their own suite directory; Robot reads variables from the process environment. GitHub Actions uses repository secrets instead of local `.env` files.

| Variable | Used by | Description |
|---|---|---|
| `FIORI_USERNAME` / `FIORI_PASSWORD` | Fiori suites, Jenkins, GitHub Actions | Fiori launchpad credentials |
| `BASE_URL` | Fiori suites | Fiori launchpad logon URL; defaults to `https://account.hanatrial.ondemand.com/` |
| `FIORI_LANGUAGE` | Fiori suites | SAP language code selected on the logon page; default `EN` |
| `BROWSER` | Robot, pytest | Browser engine (`chromium`, `firefox`, or `webkit`) |
| `HEADLESS` | Robot, pytest | Run browser headlessly (`true` / `false`) |
| `BROWSER_LOCALE` | Fiori suites | Browser locale used before the language is selected; default `en-US` |
| `JENKINS_ADMIN_ID` | Jenkins | Local Jenkins admin username; default `admin` |
| `JENKINS_ADMIN_PASSWORD` | Jenkins | Local Jenkins admin password; set this explicitly |
| `JENKINS_UID` / `JENKINS_GID` | Jenkins | Container user and group IDs |

For suite-specific prerequisites, installation, commands, and reports, use the corresponding guide in the [test suites](#test-suites) table.

To enable the repository's optional pre-commit hook:

```bash
git config core.hooksPath .githooks
```

The hook runs the available type/lint checks for changed TypeScript and Python suite files. Run `.githooks/pre-commit --all` to invoke all configured checks manually. On Windows, use Git Bash or WSL for the hook.

## CI and Docker

### Docker Compose and Jenkins quick start

The Compose setup runs Jenkins and a Docker-in-Docker sidecar. Jenkins builds each suite's runner image and runs its pipeline in a container.

```bash
docker compose build jenkins
docker compose up -d jenkins
docker compose logs -f jenkins
```

Open <http://localhost:8081> and sign in with `JENKINS_ADMIN_ID` and `JENKINS_ADMIN_PASSWORD`. The jobs are:

- `fiori-robot-e2e`
- `fiori-playwright-e2e`
- `fiori-python-e2e`

The first start applies `jenkins.yaml`, creates the Fiori Jenkins credential from `FIORI_USERNAME` / `FIORI_PASSWORD`, and generates an SSH key for GitHub checkout. Add the public key to GitHub and the matching private key as Jenkins credential `git-ssh-credentials` (see [Jenkins setup](#jenkins-setup)). The private key is printed to the Jenkins container log, so restrict access to Docker logs and rotate the key if exposed.

On first start, follow these steps:

1. Read `docker compose logs jenkins` and copy the generated public key to **GitHub → Settings → SSH and GPG keys → New SSH key**.
2. Add the matching private key in Jenkins at **Manage Jenkins → Credentials → System → Global credentials → Add Credentials** as **SSH Username with private key**:
   - ID: `git-ssh-credentials`
   - Username: `git`
   - Private key: **Enter directly** and paste the generated key
   - Passphrase: leave empty
3. The private key is also stored in the `jenkins_home` volume. To retrieve it, use `docker compose exec jenkins cat /var/jenkins_home/.ssh/id_ed25519`; treat both this file and the container logs as sensitive.

The startup script adds `github.com` to `known_hosts`. To reload `jenkins.yaml` after changing configuration, use **Manage Jenkins → Configuration as Code → Reload existing configuration**. Restart Jenkins after changing `FIORI_USERNAME` or `FIORI_PASSWORD` so the startup credential script updates `fiori-credentials`.

### Jenkins setup

The Jenkins image contains pinned plugins from `plugins.txt`; it does not install or upgrade plugins at runtime. `jenkins.yaml` configures the local admin account and pipeline jobs. The startup script `init.groovy.d/01-fiori-credentials.groovy` creates or updates only the `fiori-credentials` Jenkins credential from the Fiori environment variables. Restart Jenkins after changing those variables.

| Job | Pipeline file | Suite |
|---|---|---|
| `fiori-robot-e2e` | `robot-tests/Jenkinsfile` | Robot Framework + Browser |
| `fiori-playwright-e2e` | `playwright-test/Jenkinsfile` | Playwright Test |
| `fiori-python-e2e` | `python-tests/Jenkinsfile` | pytest + Playwright |

The pipelines use the `dind` sidecar over TLS; the host Docker socket is not mounted. Each test stage uses the shared `fiori-trial-account` lock so only one suite drives the SAP system at a time. The lock does not coordinate with local runs or GitHub Actions, so avoid overlapping runs across environments as well.

Each pipeline checks out the repository, builds its runner image, and runs its suite inside that image. The Playwright pipeline repopulates its `playwright_node_modules` named volume from the freshly built image on each run. The test workspace is mounted at the same path inside the `dind` sidecar and test container so the checked-out files are available to the runner. All three pipelines take `BASE_URL`, `BROWSER`, `HEADLESS` and `FIORI_LANGUAGE` from the host `.env` through the `FIORI_TEST_*` variables that Compose injects, so a stale job parameter cannot shadow them; the remaining build parameters only select tests: `ROBOT_INCLUDE` / `ROBOT_EXCLUDE` (Robot), `PW_PROJECT`, `PW_GREP` and `PW_DEBUG` (Playwright), and `PYTEST_MARKERS` / `PYTEST_K_EXPR` (pytest).

Jenkins publishes HTML reports for each suite and archives failure artifacts. Robot produces `results/xunit.xml`; Playwright and pytest produce JUnit XML under `test-results/`. Screenshots, videos, traces, and Robot output files are archived when available.

To configure GitHub checkout, add the generated public key to GitHub. In Jenkins, add the corresponding private key as an **SSH Username with private key** credential with ID `git-ssh-credentials`, username `git`, and no passphrase. Keep both the Jenkins logs and `jenkins_home/.ssh/` private-key file protected.

### Docker images

| Image | Dockerfile | Purpose |
|---|---|---|
| `jenkins-local:lts` | `Dockerfile.jenkins` | Jenkins controller and Docker CLI |
| `robot-local:latest` | `Dockerfile.robot` | Robot Framework + Browser runner |
| `playwright-local:latest` | `Dockerfile.playwright` | Playwright Test runner |
| `python-tests-local:latest` | `Dockerfile.python-tests` | pytest + Playwright runner |

The suite pipelines build their runner image through the `dind` sidecar. Build layers are cached in the `dind_storage` volume.

### GitHub Actions

`.github/workflows/e2e-tests.yml` is a manual `workflow_dispatch` workflow. It runs on GitHub-hosted Ubuntu runners, uses repository secrets (not `.env`), and publishes test reports. It remains manual because it needs the repository secrets and drives a shared SAP system.

Required repository secrets:

| Secret | Required | Description |
|---|---|---|
| `FIORI_USERNAME` | Yes | Fiori launchpad username |
| `FIORI_PASSWORD` | Yes | Fiori launchpad password |
| `BASE_URL` | No | Defaults to `https://account.hanatrial.ondemand.com/` |
| `FIORI_LANGUAGE` | No | Defaults to `EN` |

Add secrets under **Settings → Secrets and variables → Actions → New repository secret**, or with the GitHub CLI:

```bash
gh secret set FIORI_USERNAME
gh secret set FIORI_PASSWORD
```

Optional values can be added with `gh secret set BASE_URL` and `gh secret set FIORI_LANGUAGE`. To upload values from the local `.env` in one command, use `gh secret set -f .env` from the repository root. This uploads every key in the file; the workflow uses only the keys listed above. The `.env` file remains local and ignored by Git.

Run from the Actions tab or with GitHub CLI:

```bash
gh workflow run e2e-tests.yml -f suite=all -f browser=chromium
```

The `suite` input accepts `all`, `playwright`, `python`, or `robot`; `browser` accepts `chromium`, `firefox`, or `webkit`. With `suite=all`, the jobs run sequentially (Playwright, pytest, then Robot), and later jobs are skipped if one fails. GitHub Actions runs are serialized in the `fiori-trial-account` concurrency group, but that does not coordinate with Jenkins or local runs.

Each job uploads its report and failure artifacts with 14-day retention: Playwright reports/traces/screenshots/video, pytest reports/screenshots/traces, and Robot reports plus `xunit.xml`. GitHub-hosted runners are ephemeral, so each run installs dependencies and browser binaries.

### GitHub Pages reports

To enable Pages with GitHub CLI (requires repository admin access), run this once:

```bash
gh api --method POST -H "Accept: application/vnd.github+json" \
  /repos/turicsabaistvan/fiori/pages -f build_type="workflow"
```

If Pages is already enabled and the POST returns `409`, update the build source with `PUT`:

```bash
gh api --method PUT -H "Accept: application/vnd.github+json" \
  /repos/turicsabaistvan/fiori/pages -f build_type="workflow"
```

Alternatively, select **Settings → Pages → Build and deployment → Source → GitHub Actions**. For a fork, replace `turicsabaistvan/fiori` with the fork's `owner/repo`. Reports are published after the next workflow run.

## Troubleshooting

- **Jenkins stays at “Getting ready to work”:** check `docker compose logs jenkins` for `SEVERE` or JCasC errors; verify `JENKINS_ADMIN_ID`, `JENKINS_ADMIN_PASSWORD`, `FIORI_USERNAME`, and `FIORI_PASSWORD`, then restart Jenkins.
- **`No such DSL method 'lock' found`:** rebuild the Jenkins image; the `lockable-resources` plugin is required.
- **`No such DSL method 'publishHTML' found`:** verify the `htmlpublisher` plugin is included in `plugins.txt` and rebuild the image.
- **A pipeline cannot connect to Docker:** check that the `dind` service is healthy and inspect `docker compose logs dind`.
- **GitHub checkout fails over SSH:** verify the generated key, GitHub public key registration, `known_hosts`, and the `git-ssh-credentials` Jenkins credential.

## Security and safety

- Credentials belong in environment variables, the Jenkins credential store, or GitHub Actions secrets. `.env` is ignored by Git; never commit real credentials.
- Any credential that was ever committed must be rotated and purged from Git history; removing the file from the current revision is not sufficient. An earlier revision contained a hard-coded Fiori credential in the now-removed `robot-tests/resources/data/credentials.resource`; treat it as compromised, rotate it, and purge it from history with `git filter-repo` or BFG before publishing the repository.
- Compose publishes Jenkins on all host interfaces by default: `0.0.0.0:8081` for the UI and `0.0.0.0:50001` for the agent port. If the host is reachable from an untrusted network, change the UI mapping to `127.0.0.1:8081:8080` and remove the `50001` mapping, or place Jenkins behind TLS and a reverse proxy.
- Set `JENKINS_ADMIN_PASSWORD` explicitly. Compose falls back to `admin` if it is unset; that fallback is not safe.
- Protect the Jenkins Docker logs and `jenkins_home` volume because the private GitHub SSH key is printed to logs and stored in the volume.
- The Docker-in-Docker sidecar is privileged. It is connected to the internal test network over TLS; the host Docker socket is not mounted into containers.
- This is an internal/portfolio test project, not intended for production use against an SAP Fiori trial landscape without the account owner's consent.

## License

Internal / portfolio project.
