import { test } from '@fixtures/fiori.fixture';

import { DEFAULT_BASE_URL, requireEnv } from '../utils/env';
import { loginWithConfiguredUser, logoutFromFiori } from '../utils/session';

const APP_CATALOG = 'Z_TEST_CAT';
const APP_NAME = 'User Maintenance';
const EXPECTED_CLIENT = '800';

// A demo recording keeps the videos of the passing run; regular runs only
// retain them on failure. The object form records at the README video size.
const video =
  process.env.RECORD_VIDEO === 'on'
    ? { mode: 'on' as const, size: { width: 1280, height: 720 } }
    : ('retain-on-failure' as const);
test.use({ video });

/**
 * Opens the User Maintenance app from the launchpad All My Apps view, searches
 * in its user name input help, then closes the app and signs out. No business
 * data is changed.
 */
test.describe('Fiori User Maintenance App', () => {
  // The journey needs more than the suite-wide two-minute timeout.
  test.describe.configure({ timeout: 4 * 60_000 });

  test('open User Maintenance from All My Apps and check the user name input help', async ({
    baseURL,
    loginPage,
    launchpadPage,
    allMyAppsPage,
  }) => {
    const userName = requireEnv('FIORI_USERNAME');
    const baseUrl = baseURL ?? DEFAULT_BASE_URL;

    await loginWithConfiguredUser(loginPage, launchpadPage, baseUrl);
    await launchpadPage.assertHomePageIsIntact(EXPECTED_CLIENT, baseUrl);

    await allMyAppsPage.openAllMyApps();
    await allMyAppsPage.selectDataSource(APP_CATALOG);

    const userMaintenancePage = await allMyAppsPage.openAppInNewTab(APP_NAME);
    await userMaintenancePage.assertAppIsOpen();
    await userMaintenancePage.fillUserName(userName);
    await userMaintenancePage.openUserNameInputHelp();
    await userMaintenancePage.closeInputHelp();
    await userMaintenancePage.closeApp();

    await launchpadPage.bringToFront();
    await launchpadPage.assertHomePageIsIntact(EXPECTED_CLIENT, baseUrl);

    await logoutFromFiori(launchpadPage, loginPage);
  });
});
