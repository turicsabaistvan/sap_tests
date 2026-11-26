/**
 * Environment helpers for the E2E suite.
 *
 * Credentials must be provided via FIORI_USERNAME / FIORI_PASSWORD.
 */

export function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

export function optionalEnv(name: string, fallback: string): string {
  const value = process.env[name];
  return value && value.length > 0 ? value : fallback;
}
