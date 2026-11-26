import { test } from '@fixtures/fiori.fixture';

import { optionalEnv, requireEnv } from '../utils/env';

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
    const username = requireEnv('FIORI_USERNAME');
    const password = requireEnv('FIORI_PASSWORD');
    const language = optionalEnv('FIORI_LANGUAGE', 'EN');

    await loginPage.open(
      baseURL ?? 'https://account.hanatrial.ondemand.com/'
    );
    await loginPage.assertLogonPageIsDisplayed();
    await loginPage.setLanguage(language);
    await loginPage.fillUsername(username);
    await loginPage.fillPassword(password);
    await loginPage.submitLogin();
    await launchpadPage.waitForLaunchpad();
    await launchpadPage.logout();
    await loginPage.assertLogonPageIsDisplayed();
  });
});
