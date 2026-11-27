import { optionalEnv, requireEnv } from './env';
import type { LaunchpadPage } from '@pages/launchpad.page';
import type { LoginPage } from '@pages/login.page';

/**
 * Shared session keywords so both specs sign in and out the same way.
 */

export async function loginWithConfiguredUser(
  loginPage: LoginPage,
  launchpadPage: LaunchpadPage,
  baseUrl: string
): Promise<void> {
  const username = requireEnv('FIORI_USERNAME');
  const password = requireEnv('FIORI_PASSWORD');
  const language = optionalEnv('FIORI_LANGUAGE', 'EN');

  await loginPage.open(baseUrl);
  await loginPage.assertLogonPageIsDisplayed();
  await loginPage.setLanguage(language);
  await loginPage.fillUsername(username);
  await loginPage.fillPassword(password);
  await loginPage.submitLogin();
  await launchpadPage.waitForLaunchpad();
}

export async function logoutFromFiori(
  launchpadPage: LaunchpadPage,
  loginPage: LoginPage
): Promise<void> {
  await launchpadPage.logout();
  await loginPage.assertLogonPageIsDisplayed();
}
