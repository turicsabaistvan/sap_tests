import { test } from '@fixtures/fiori.fixture';

import { DEFAULT_BASE_URL } from '../utils/env';
import { loginWithConfiguredUser, logoutFromFiori } from '../utils/session';

/**
 * Smoke test for the SAP Fiori launchpad logon flow.
 *
 * Opens BASE_URL, sets the language on the logon page, signs in with the
 * configured credentials and signs out again. It does not change business
 * data.
 */
test.describe('Fiori Login Logout', () => {
  test('login with configured language and logout', async ({
    baseURL,
    loginPage,
    launchpadPage,
  }) => {
    await loginWithConfiguredUser(
      loginPage,
      launchpadPage,
      baseURL ?? DEFAULT_BASE_URL
    );
    await logoutFromFiori(launchpadPage, loginPage);
  });
});
