import { Page } from '@playwright/test';

import { BasePage } from '@pages/base.page';
import { LoginSelectors } from '@selectors/login.selectors';

/**
 * Page Object for the SAP Fiori launchpad logon page.
 */
export class LoginPage extends BasePage {
  constructor(page: Page) {
    super(page);
  }

  async open(url: string): Promise<void> {
    await this.page.goto(url, { waitUntil: 'domcontentloaded' });
    await this.waitForVisible(LoginSelectors.loginForm, 30_000);
  }

  async assertLogonPageIsDisplayed(): Promise<void> {
    await this.waitForVisible(LoginSelectors.usernameInput, 30_000);
  }

  async setLanguage(language: string): Promise<void> {
    // The language options are populated by the logon page script, so the
    // <select> is empty in the served HTML.
    await this.waitForVisible(LoginSelectors.languageSelect);
    await this.page.waitForFunction(
      (selector) => document.querySelectorAll(selector).length > 0,
      LoginSelectors.languageOptions,
      { timeout: 15_000 }
    );
    await this.page.selectOption(LoginSelectors.languageSelect, {
      value: language,
    });

    const selected = await this.page
      .locator(LoginSelectors.languageSelect)
      .inputValue();
    if (selected !== language) {
      throw new Error(
        `Expected logon language ${language}, but ${selected} was selected.`
      );
    }

    // Selecting a language can reload the logon page in some releases.
    await this.assertLogonPageIsDisplayed();
  }

  async fillUsername(username: string): Promise<void> {
    await this.fill(LoginSelectors.usernameInput, username);
  }

  async fillPassword(password: string): Promise<void> {
    await this.fill(LoginSelectors.passwordInput, password);
  }

  async submitLogin(): Promise<void> {
    await this.click(LoginSelectors.submitButton);
  }
}
