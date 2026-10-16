import { test, expect, type Page } from '@playwright/test';
import { fixedEntry, mockApi, newState } from './mocks';

/**
 * Onboarding (BEH-ONBOARD-1), settings: vice (BEH-VICE-1), appearance (BEH-THEME-1) and reset
 * (BEH-RESET-1). Phone-sized; screenshots are written for review and are not committed.
 */

test.use({ viewport: { width: 390, height: 844 }, timezoneId: 'UTC' });

const shot = (page: Page, name: string) =>
  page.screenshot({ path: `e2e/screenshots/${name}.png`, fullPage: true, animations: 'disabled' });

const next = (page: Page) => page.getByRole('button', { name: 'Next' }).click();

test('onboarding walks four steps, sends the choices, and lands on the dashboard', async ({ page }) => {
  const state = await mockApi(page, newState({ signedIn: true, onboarded: false }));
  await page.goto('./');

  await expect(page.getByText('1. PRIMARY ENGINE')).toBeVisible();
  await page.getByRole('radio', { name: /SWIM/ }).click();
  await shot(page, 'onboarding');
  await next(page);

  // Swim: lengths, up to 3000.
  await expect(page.getByText('2. SWIM VOLUME')).toBeVisible();
  await expect(page.getByText('0 LENGTHS')).toBeVisible();
  await expect(page.getByText('BEGINNER')).toBeVisible();
  await page.getByLabel('Weekly volume').fill('1500');
  await expect(page.getByText('1500 LENGTHS')).toBeVisible();
  await expect(page.getByText('ELITE')).toBeVisible(); // 1500 lengths / 30 = 50 km-equivalent
  await next(page);

  await expect(page.getByText('3. VICE SETUP')).toBeVisible();
  await expect(page.getByLabel('Vice emoji')).toHaveValue('🍕');
  await page.getByRole('button', { name: 'Pick 🎮' }).click();
  await expect(page.getByLabel('Vice emoji')).toHaveValue('🎮');
  await next(page);

  await expect(page.getByText('4. SUSTAINABILITY AUDIT')).toBeVisible();
  await page.getByLabel('Vices per week').fill('30');
  await expect(page.getByText('HIGH VICE LOAD', { exact: false })).toBeVisible();

  const sent = page.waitForRequest('**/api/profile/onboard');
  await page.getByRole('button', { name: 'Enter the arena' }).click();
  expect((await sent).postDataJSON()).toEqual({ sport: 'Swim', weeklyVolume: 1500, viceEmoji: '🎮', weeklyViceCount: 30 });

  await expect(page.getByText('CURRENT WEEK')).toBeVisible();
  await expect(page.getByTestId('balance')).toHaveText('0.00 🎮');
  expect(state.onboarded).toBe(true);
});

test('onboarding can step back, and shows a server refusal inline', async ({ page }) => {
  await mockApi(page, newState({ signedIn: true, onboarded: false, onboardError: 'That is not an emoji.' }));
  await page.goto('./');

  await next(page);
  await page.getByRole('button', { name: 'Back' }).click();
  await expect(page.getByText('1. PRIMARY ENGINE')).toBeVisible();

  for (let i = 0; i < 3; i++) await next(page);
  await page.getByRole('button', { name: 'Enter the arena' }).click();
  await expect(page.getByRole('alert')).toHaveText('That is not an emoji.');
  await expect(page.getByText('4. SUSTAINABILITY AUDIT')).toBeVisible();
});

test('settings: change the vice, and the dashboard reflects it', async ({ page }) => {
  await mockApi(page, newState({ signedIn: true, entries: [fixedEntry('v', 'Vice', null, 2, '2026-10-14T21:30:00Z')] }));
  await page.goto('./');
  await expect(page.getByTestId('balance')).toHaveText('-2.00 🍺');

  await page.getByRole('button', { name: 'Settings' }).click();
  const dialog = page.getByRole('dialog', { name: 'Settings' });
  await expect(dialog.getByLabel('Pick an emoji')).toHaveValue('🍺');
  await shot(page, 'settings');

  await dialog.getByRole('button', { name: 'Pick 🍩' }).click();
  await dialog.getByRole('button', { name: 'Save' }).click();
  await expect(dialog).toBeHidden();
  await expect(page.getByTestId('balance')).toHaveText('-2.00 🍩');
});

test('settings: appearance offers Auto, Light and Dark; Auto follows the device', async ({ page }) => {
  await page.emulateMedia({ colorScheme: 'light' });
  await mockApi(page, newState({ signedIn: true }));
  await page.goto('./');
  const html = page.locator('html');
  await expect(html).toHaveAttribute('data-theme', 'dark'); // the default is dark until chosen

  await page.getByRole('button', { name: 'Settings' }).click();
  const appearance = page.getByRole('dialog').getByRole('radiogroup', { name: 'Appearance' });
  await appearance.getByRole('radio', { name: 'Auto' }).click();
  await expect(html).toHaveAttribute('data-theme', 'light');
  await page.emulateMedia({ colorScheme: 'dark' });
  await expect(html).toHaveAttribute('data-theme', 'dark');
  await appearance.getByRole('radio', { name: 'Light' }).click();
  await expect(html).toHaveAttribute('data-theme', 'light');
  await expect(appearance.getByRole('radio', { name: 'Light' })).toHaveAttribute('aria-checked', 'true');
});

test('settings: reset asks once, can be backed out of, then returns to onboarding', async ({ page }) => {
  const state = await mockApi(page, newState({ signedIn: true, entries: [fixedEntry('a', 'Activity', 'Run', 4, '2026-10-13T07:05:00Z')] }));
  await page.goto('./');

  await page.getByRole('button', { name: 'Settings' }).click();
  const dialog = page.getByRole('dialog', { name: 'Settings' });
  await dialog.getByRole('button', { name: 'Reset app' }).click();
  await expect(dialog.getByText("It can't be undone", { exact: false })).toBeVisible();
  await dialog.getByRole('button', { name: 'Keep my data' }).click();
  await expect(dialog.getByRole('button', { name: 'Reset app' })).toBeVisible();
  expect(state.calls).not.toContain('POST /api/profile/reset');

  await dialog.getByRole('button', { name: 'Reset app' }).click();
  await dialog.getByRole('button', { name: 'Yes, reset everything' }).click();
  await expect(page.getByText('1. PRIMARY ENGINE')).toBeVisible();
  await expect(dialog).toBeHidden();
  expect(state.entries).toHaveLength(0);
});
