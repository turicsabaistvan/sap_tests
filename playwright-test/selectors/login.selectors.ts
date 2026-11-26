/**
 * Selectors for the SAP Fiori launchpad logon page.
 */
export const LoginSelectors = {
  loginForm: '#LOGIN_FORM',
  languageSelect: '#LANGUAGE_SELECT',
  languageOptions: '#LANGUAGE_SELECT option',
  usernameInput: '#USERNAME_FIELD-inner',
  passwordInput: '#PASSWORD_FIELD-inner',
  submitButton: '#LOGIN_LINK',
  errorBlock: '#LOGIN_ERROR_BLOCK',
} as const;
