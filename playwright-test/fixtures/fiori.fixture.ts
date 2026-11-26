import { test as base } from '@playwright/test';

import { LaunchpadPage } from '@pages/launchpad.page';
import { LoginPage } from '@pages/login.page';

/**
 * Custom fixtures that expose page objects to the tests.
 * Tests receive typed page objects instead of raw selectors.
 */
type FioriFixtures = {
  loginPage: LoginPage;
  launchpadPage: LaunchpadPage;
};

export const test = base.extend<FioriFixtures>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },
  launchpadPage: async ({ page }, use) => {
    await use(new LaunchpadPage(page));
  },
});

export { expect } from '@playwright/test';
