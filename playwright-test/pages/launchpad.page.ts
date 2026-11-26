import { Page } from '@playwright/test';

import { BasePage } from '@pages/base.page';
import { LaunchpadSelectors } from '@selectors/launchpad.selectors';
import { LoginSelectors } from '@selectors/login.selectors';

/**
 * Page Object for the SAP Fiori launchpad shell.
 */
export class LaunchpadPage extends BasePage {
  private static readonly LAUNCHPAD_TIMEOUT = 60_000;

  constructor(page: Page) {
    super(page);
  }

  async waitForLaunchpad(): Promise<void> {
    // The profile head item is created disabled and only enabled once the
    // shell has finished loading, so "enabled" is the readiness signal.
    try {
      await this.waitForEnabled(
        LaunchpadSelectors.meAreaButton,
        LaunchpadPage.LAUNCHPAD_TIMEOUT
      );
    } catch (error) {
      await this.reportLoginErrorIfDisplayed();
      throw error;
    }
  }

  async reportLoginErrorIfDisplayed(): Promise<void> {
    if (!(await this.isVisible(LoginSelectors.errorBlock, 2_000))) {
      return;
    }
    const message = await this.page
      .locator(LoginSelectors.errorBlock)
      .innerText();
    throw new Error(`Login failed: ${message.trim()}`);
  }

  async logout(): Promise<void> {
    await this.openUserActionsMenu();
    await this.openSignOutAction();
    await this.confirmSignOutIfRequested();
    await this.waitForVisible(
      LoginSelectors.usernameInput,
      LaunchpadPage.LAUNCHPAD_TIMEOUT
    );
  }

  private async openUserActionsMenu(): Promise<void> {
    if (await this.isVisible(LaunchpadSelectors.meAreaButton, 5_000)) {
      await this.click(LaunchpadSelectors.meAreaButton);
      return;
    }
    await this.click(LaunchpadSelectors.userActionsButton, 30_000);
  }

  private async openSignOutAction(): Promise<void> {
    if (await this.isVisible(LaunchpadSelectors.signOutItem, 10_000)) {
      await this.click(LaunchpadSelectors.signOutItem);
      return;
    }
    await this.click(LaunchpadSelectors.signOutItemText);
  }

  private async confirmSignOutIfRequested(): Promise<void> {
    if (await this.isVisible(LaunchpadSelectors.signOutConfirmButton, 5_000)) {
      await this.click(LaunchpadSelectors.signOutConfirmButton);
    }
  }
}
