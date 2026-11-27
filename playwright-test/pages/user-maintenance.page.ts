import { expect, Page } from '@playwright/test';

import { BasePage } from '@pages/base.page';
import { LaunchpadSelectors } from '@selectors/launchpad.selectors';
import { UserMaintenanceSelectors } from '@selectors/user-maintenance.selectors';

/**
 * Page Object for the User Maintenance app (SU01) opened from the launchpad.
 * The object is bound to the app tab, not to the launchpad page.
 */
export class UserMaintenancePage extends BasePage {
  private static readonly APP_TIMEOUT = 60_000;
  private static readonly SEARCH_TIMEOUT = 30_000;

  constructor(page: Page) {
    super(page);
  }

  async assertAppIsOpen(): Promise<void> {
    await this.waitForVisible(
      UserMaintenanceSelectors.userNameInput,
      UserMaintenancePage.APP_TIMEOUT
    );
    await this.assertNoVisibleElements(
      LaunchpadSelectors.messageBox,
      'The User Maintenance app shows an error dialog.'
    );
  }

  async fillUserName(userName: string): Promise<void> {
    await this.fill(UserMaintenanceSelectors.userNameInput, userName);
  }

  async openUserNameInputHelp(): Promise<void> {
    await this.click(
      UserMaintenanceSelectors.inputHelpButton,
      UserMaintenancePage.APP_TIMEOUT
    );
    await this.waitForVisible(
      UserMaintenanceSelectors.inputHelpDialog,
      UserMaintenancePage.APP_TIMEOUT
    );
    await this.waitForVisible(
      UserMaintenanceSelectors.inputHelpFind,
      UserMaintenancePage.APP_TIMEOUT
    );
    await this.click(
      UserMaintenanceSelectors.inputHelpFind,
      UserMaintenancePage.APP_TIMEOUT
    );
    await this.waitForVisible(
      UserMaintenanceSelectors.inputHelpResults,
      UserMaintenancePage.SEARCH_TIMEOUT
    );

    // The result row cells are scrolled out of the visible area, so only
    // their count proves that the search returned users.
    const rows = this.page.locator(UserMaintenanceSelectors.inputHelpResultRows);
    await expect(
      rows,
      'The user name input help returned no users for the configured user name.'
    ).not.toHaveCount(0, { timeout: UserMaintenancePage.SEARCH_TIMEOUT });
  }

  /**
   * Presses Cancel until the input help closes. SAP swallows the first click
   * while the search is still processing, so the click is retried.
   */
  async closeInputHelp(): Promise<void> {
    const dialog = this.page.locator(UserMaintenanceSelectors.inputHelpDialog);
    await expect(async () => {
      if (
        await this.isVisible(UserMaintenanceSelectors.inputHelpCancel, 1_000)
      ) {
        await this.click(UserMaintenanceSelectors.inputHelpCancel, 3_000);
      }
      await expect(dialog).toBeHidden({ timeout: 5_000 });
    }).toPass({
      timeout: UserMaintenancePage.SEARCH_TIMEOUT,
      intervals: [2_000],
    });
  }

  async closeApp(): Promise<void> {
    await this.page.close();
  }
}
