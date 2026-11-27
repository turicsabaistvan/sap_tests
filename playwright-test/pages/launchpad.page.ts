import { expect, Page } from '@playwright/test';

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

  /**
   * Asserts that the configured client is on the home page, without an error
   * dialog and without a redirect away from the configured URL.
   */
  async assertHomePageIsIntact(
    expectedClient: string,
    baseUrl: string
  ): Promise<void> {
    await this.waitForVisible(
      LaunchpadSelectors.dashboardGroups,
      LaunchpadPage.LAUNCHPAD_TIMEOUT
    );
    await this.assertNoVisibleElements(
      LaunchpadSelectors.messageBox,
      'The launchpad home page shows an error dialog.'
    );

    // SAP stores the client in the session after logon, so the loaded URL no
    // longer carries it; the configured BASE_URL must target the client.
    if (!baseUrl.includes(`sap-client=${expectedClient}`)) {
      throw new Error(
        `The configured BASE_URL does not target client ${expectedClient}.`
      );
    }

    const currentUrl = this.page.url();
    expect(
      currentUrl.split('#')[0].split('?')[0],
      `The launchpad navigated away from the configured URL (current url: ${currentUrl}).`
    ).toBe(baseUrl.split('#')[0].split('?')[0]);
    expect(
      currentUrl,
      'The launchpad did not return to the home page.'
    ).toContain('#Shell-home');
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
