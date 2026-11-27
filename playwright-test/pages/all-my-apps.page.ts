import { expect, Page } from '@playwright/test';

import { BasePage } from '@pages/base.page';
import { UserMaintenancePage } from '@pages/user-maintenance.page';
import { AllMyAppsSelectors } from '@selectors/all-my-apps.selectors';

/**
 * Page Object for the launchpad "Home - Show All My Apps" view.
 *
 * The view lists the data sources (catalogs) on the left and the apps of the
 * selected catalog on the right. Clicking an app opens it in a new tab.
 */
export class AllMyAppsPage extends BasePage {
  private static readonly VIEW_TIMEOUT = 60_000;

  constructor(page: Page) {
    super(page);
  }

  async openAllMyApps(): Promise<void> {
    await this.click(
      AllMyAppsSelectors.allMyAppsButton,
      AllMyAppsPage.VIEW_TIMEOUT
    );
    await this.waitForVisible(
      AllMyAppsSelectors.dataSourcesList,
      AllMyAppsPage.VIEW_TIMEOUT
    );
  }

  async selectDataSource(catalog: string): Promise<void> {
    const selector = `${AllMyAppsSelectors.dataSourceItem}:has-text(${JSON.stringify(catalog)})`;
    await this.waitForVisible(selector, AllMyAppsPage.VIEW_TIMEOUT);
    await this.click(selector, AllMyAppsPage.VIEW_TIMEOUT);
  }

  /**
   * Clicks the app option and returns the page object bound to the tab it
   * opens. The page is read-only here: it only fills and searches fields.
   */
  async openAppInNewTab(appName: string): Promise<UserMaintenancePage> {
    // Start waiting before the click, otherwise the new page event is missed.
    const popupPromise = this.page
      .context()
      .waitForEvent('page', { timeout: AllMyAppsPage.VIEW_TIMEOUT });
    const option = this.page
      .getByRole('option', { name: appName, exact: true })
      .filter({ visible: true })
      .first();
    await expect(
      option,
      `The All My Apps view has no application titled "${appName}".`
    ).toBeVisible({ timeout: AllMyAppsPage.VIEW_TIMEOUT });

    await option.click();
    const popup = await popupPromise;
    await popup.waitForLoadState('domcontentloaded');
    return new UserMaintenancePage(popup);
  }
}
