/**
 * Selectors for the launchpad "Home - Show All My Apps" view.
 *
 * The app option is addressed by role and name in the page object, because its
 * accessible name is the configured app title.
 */
export const AllMyAppsSelectors = {
  allMyAppsButton: 'role=button[name="Home - Show All My Apps"]',
  dataSourcesList: '#sapUshellAllMyAppsDataSourcesList',
  dataSourceItem:
    '[id*="sapUshellAllMyAppsDataSourcesList"][id$="-content"]',
} as const;
