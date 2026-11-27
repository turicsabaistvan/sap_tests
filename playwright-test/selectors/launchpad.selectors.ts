/**
 * Selectors for the SAP Fiori launchpad shell header and profile menu.
 */
export const LaunchpadSelectors = {
  meAreaButton: '#meAreaHeaderButton',
  userActionsButton: '#userActionsMenuHeaderButton',
  // The sign out entry carries a generated id whose suffix is stable.
  signOutItem: '[id$="logoutBtn"]',
  signOutItemText: 'text="Sign Out"',
  signOutConfirmButton: '#__mbox-btn-0',
  dashboardGroups: ':is(#dashboardGroups, .sapUshellDashboardGroupsContainer)',
  messageBox: '.sapMMessageBox:visible',
} as const;
