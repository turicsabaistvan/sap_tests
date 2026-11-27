/**
 * Selectors for the User Maintenance app opened from the launchpad.
 *
 * The ids and titles come from the SAP GUI for HTML rendering of the app and
 * are verified against the target system.
 */
export const UserMaintenanceSelectors = {
  userNameInput: 'input[title^="User Name in User Master"]',
  inputHelpButton: '#ls-inputfieldhelpbutton',
  inputHelpDialog: '#SearchHelp1',
  inputHelpFind: '[title="Find"]:visible',
  inputHelpCancel: '[title="Cancel"]:visible',
  inputHelpResults: '#SHresultgrid1',
  // One cell per hit in the search help result grid.
  inputHelpResultRows: '#SHresultgrid1-mrss-cont-left td[id^="sh["]',
} as const;
