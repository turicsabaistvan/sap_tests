import { expect, Page } from '@playwright/test';

/**
 * Base class for all page objects.
 * Provides small, shared helpers around Playwright's Page API.
 */
export abstract class BasePage {
  constructor(protected readonly page: Page) {}

  /**
   * UI5 often renders duplicate elements (for example several "Decline"
   * buttons in the audit log popup, plus their destroyed clones). Restrict
   * to visible matches and use the first one like the Robot suite does
   * instead of failing Playwright's strict mode.
   */
  protected async waitForVisible(
    selector: string,
    timeout = 15_000
  ): Promise<void> {
    await this.page
      .locator(selector)
      .filter({ visible: true })
      .first()
      .waitFor({ state: 'visible', timeout });
  }

  protected async waitForEnabled(
    selector: string,
    timeout = 15_000
  ): Promise<void> {
    const locator = this.page.locator(selector).first();
    await locator.waitFor({ state: 'visible', timeout });
    await expect(locator).toBeEnabled({ timeout });
  }

  protected async click(selector: string, timeout = 15_000): Promise<void> {
    const locator = this.page
      .locator(selector)
      .filter({ visible: true })
      .first();
    await locator.waitFor({ state: 'visible', timeout });
    await locator.click({ timeout });
  }

  protected async fill(selector: string, value: string): Promise<void> {
    const locator = this.page
      .locator(selector)
      .filter({ visible: true })
      .first();
    await locator.waitFor({ state: 'visible', timeout: 15_000 });
    await locator.fill(value);
  }

  /**
   * Asserts that no element of the selector is visible, for example that the
   * launchpad did not show an error dialog.
   */
  protected async assertNoVisibleElements(
    selector: string,
    message: string
  ): Promise<void> {
    await expect(this.page.locator(selector), message).toHaveCount(0);
  }

  /**
   * Activates this page's tab. Used after an app tab is closed so that
   * assertions continue on the launchpad page.
   */
  async bringToFront(): Promise<void> {
    await this.page.bringToFront();
  }

  protected async isVisible(selector: string, timeout = 3_000): Promise<boolean> {
    try {
      await this.page
        .locator(selector)
        .filter({ visible: true })
        .first()
        .waitFor({ state: 'visible', timeout });
      return true;
    } catch (error) {
      // Only a timeout means "not visible"; every other error must surface.
      if (error instanceof Error && error.name === 'TimeoutError') {
        return false;
      }
      throw error;
    }
  }
}