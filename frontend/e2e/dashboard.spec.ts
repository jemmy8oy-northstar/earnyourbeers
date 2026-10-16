import { test, expect, type Page } from '@playwright/test';
import { fixedEntry, mockApi, newState } from './mocks';

/**
 * Sign-in -> dashboard -> logging, the settlement report, history and onboarding, against the
 * in-memory fake backend in mocks.ts. Phone-sized (390x844) like the real user; screenshots go
 * to e2e/screenshots/ for review (they assert nothing).
 */

test.use({ viewport: { width: 390, height: 844 }, timezoneId: 'UTC' });

const shot = (page: Page, name: string) =>
  page.screenshot({ path: `e2e/screenshots/${name}.png`, fullPage: true, animations: 'disabled' });

test('sign in with wrong then right credentials reaches the dashboard, and sign out returns', async ({ page }) => {
  await mockApi(page, newState());
  await page.goto('./');

  await expect(page.getByRole('heading', { name: 'Earn Your Vices', level: 1 })).toBeVisible();
  await expect(page).toHaveTitle('Earn Your Vices');
  await shot(page, 'sign-in');

  await page.getByLabel('Username').fill('james');
  await page.getByLabel('Password').fill('wrong');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page.getByRole('alert')).toHaveText('Wrong username or password.');

  await page.getByLabel('Password').fill('correct horse');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page.getByText('CURRENT WEEK')).toBeVisible();

  await page.getByRole('button', { name: 'Sign out' }).click();
  await expect(page.getByRole('button', { name: 'Sign in' })).toBeVisible();
});

test('creating an account lands on the onboarding placeholder; a taken name shows inline', async ({ page }) => {
  await mockApi(page, newState());
  await page.goto('./');

  await page.getByRole('button', { name: 'Create an account' }).click();
  await page.getByLabel('Username').fill('james');
  await page.getByLabel('Password').fill('x');
  await page.getByRole('button', { name: 'Create account' }).click();
  await expect(page.getByRole('alert')).toHaveText('That username is taken.');

  await page.getByLabel('Username').fill('newbie');
  await page.getByRole('button', { name: 'Create account' }).click();
  await expect(page.getByText('Onboarding coming next')).toBeVisible();
});

test('an existing session goes straight to the dashboard: balance, league, log', async ({ page }) => {
  await mockApi(page, newState({
    signedIn: true,
    entries: [
      fixedEntry('a', 'Activity', 'Run', 4, '2026-10-13T07:05:00Z'),
      fixedEntry('b', 'Vice', null, 1, '2026-10-14T21:30:00Z'),
      fixedEntry('c', 'Activity', 'Swim', 20, '2026-10-15T18:45:00Z'),
    ],
  }));
  await page.goto('./');

  // 4 km run = 2, 20 lengths = 0.33, one vice = -1 -> 1.33 in credit
  await expect(page.getByTestId('balance')).toHaveText('1.33 🍺');
  await expect(page.getByText('POINTS IN CREDIT')).toBeVisible();

  await expect(page.getByText('Bronze')).toBeVisible();
  await expect(page.getByText('4.50 pts')).toBeVisible();
  await expect(page.getByRole('progressbar', { name: 'League tally' })).toHaveAttribute('aria-valuenow', '4.5');

  await expect(page.getByText('Logged at 18:45')).toBeVisible();
  await expect(page.getByText('Logged at 7:05')).toBeVisible();
  // Only the newest entry carries edit/delete.
  await expect(page.getByRole('button', { name: 'Edit entry' })).toHaveCount(1);

  await shot(page, 'dashboard');
});

test('logging a run updates the balance and shows the points one unit earns', async ({ page }) => {
  const state = await mockApi(page, newState({ signedIn: true }));
  await page.goto('./');

  await expect(page.getByTestId('balance')).toHaveText('0.00 🍺');
  await expect(page.getByText('SQUARE')).toBeVisible();
  await expect(page.getByText('No activity this week.')).toBeVisible();

  const run = page.getByRole('button', { name: /^\+0\.50 .*Run/ });
  await expect(run).toBeVisible();
  await run.click();
  await expect(page.getByTestId('balance')).toHaveText('0.50 🍺');
  await expect(page.getByText('1.0 km Run')).toBeVisible();

  await page.getByRole('button', { name: 'Log 🍺' }).click();
  await page.getByRole('button', { name: 'Log 🍺' }).click();
  await expect(page.getByTestId('balance')).toHaveText('-1.50 🍺');
  await expect(page.getByText('POINTS IN DEBT')).toBeVisible();
  expect(state.entries).toHaveLength(3);
});

test('a long press on the vice asks for an amount greater than zero', async ({ page }) => {
  const state = await mockApi(page, newState({ signedIn: true }));
  await page.goto('./');

  const vice = page.getByRole('button', { name: 'Log 🍺' });
  await vice.hover();
  await page.mouse.down();
  await page.waitForTimeout(700);
  await page.mouse.up();

  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();
  expect(state.entries).toHaveLength(0); // the hold did not also log one

  await dialog.getByLabel(/Amount/).fill('0');
  await dialog.getByRole('button', { name: 'Log' }).click();
  await expect(dialog.getByRole('alert')).toHaveText('Enter an amount greater than 0.');

  await dialog.getByLabel(/Amount/).fill('2.5');
  await dialog.getByRole('button', { name: 'Log' }).click();
  await expect(dialog).toBeHidden();
  await expect(page.getByTestId('balance')).toHaveText('-2.50 🍺');
});

test('the newest entry can be edited (down to 0) and deleted', async ({ page }) => {
  await mockApi(page, newState({
    signedIn: true,
    entries: [fixedEntry('a', 'Activity', 'Run', 4, '2026-10-13T07:05:00Z'), fixedEntry('b', 'Vice', null, 3, '2026-10-14T21:30:00Z')],
  }));
  await page.goto('./');
  await expect(page.getByTestId('balance')).toHaveText('-1.00 🍺');

  await page.getByRole('button', { name: 'Edit entry' }).click();
  await page.getByRole('dialog').getByLabel(/Amount/).fill('0');
  await page.getByRole('dialog').getByRole('button', { name: 'Save' }).click();
  await expect(page.getByTestId('balance')).toHaveText('2.00 🍺');

  await page.getByRole('button', { name: 'Delete entry' }).click();
  await expect(page.getByTestId('balance')).toHaveText('2.00 🍺');
  await expect(page.getByText('4.0 km Run')).toBeVisible();
  // The run is now the newest, so it gained the actions.
  await expect(page.getByRole('button', { name: 'Edit entry' })).toHaveCount(1);
});

test('a pending settlement shows as a modal until "Start new week"', async ({ page }) => {
  const state = await mockApi(page, newState({
    signedIn: true,
    settlement: { weeklyNet: 6.25, outcome: 'DoublePromotion' },
  }));
  await page.goto('./');

  const dialog = page.getByRole('dialog', { name: 'Weekly settlement' });
  await expect(dialog).toBeVisible();
  await expect(dialog.getByText('+6.3 pts')).toBeVisible();
  await expect(dialog.getByText('DOUBLE PROMOTION!')).toBeVisible();
  await shot(page, 'settlement');

  await page.keyboard.press('Escape');
  await expect(dialog).toBeVisible(); // not dismissible except by the button

  await dialog.getByRole('button', { name: 'Start new week' }).click();
  await expect(dialog).toBeHidden();
  expect(state.calls).toContain('POST /api/settlement/dismiss');
});

test('each settlement outcome has its own wording', async ({ page }) => {
  for (const [outcome, text] of [['Promoted', 'PROMOTED!'], ['Demoted', 'DEMOTED'], ['PositionSecured', 'POSITION SECURED']] as const) {
    await mockApi(page, newState({ signedIn: true, settlement: { weeklyNet: -2, outcome } }));
    await page.goto('./');
    await expect(page.getByRole('dialog').getByText(text, { exact: true })).toBeVisible();
    await page.unrouteAll();
  }
});

test('past weeks can be paged back through and are read-only', async ({ page }) => {
  await mockApi(page, newState({
    signedIn: true,
    entries: [fixedEntry('a', 'Activity', 'Run', 2, '2026-10-13T07:05:00Z')],
    history: { [-1]: [fixedEntry('h', 'Vice', null, 3, '2026-10-07T20:00:00Z')] },
  }));
  await page.goto('./');

  await expect(page.getByText('CURRENT WEEK')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Next week' })).toBeDisabled();
  await page.getByRole('button', { name: 'Previous week' }).click();

  await expect(page.getByText('WEEK OF 5/10')).toBeVisible();
  await expect(page.getByTestId('balance')).toHaveText('-3.00 🍺');
  await expect(page.getByText('Logged at 20:00')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Edit entry' })).toHaveCount(0);
  await expect(page.getByRole('button', { name: 'Log 🍺' })).toHaveCount(0);
  await expect(page.getByRole('button', { name: 'Previous week' })).toBeDisabled();

  await page.getByRole('button', { name: 'Next week' }).click();
  await expect(page.getByText('CURRENT WEEK')).toBeVisible();
});

test('a user who is not onboarded sees the placeholder', async ({ page }) => {
  await mockApi(page, newState({ signedIn: true, onboarded: false }));
  await page.goto('./');
  await expect(page.getByText('Onboarding coming next')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Sign out' })).toBeVisible();
});

test('the theme toggle still works', async ({ page }) => {
  await mockApi(page, newState({ signedIn: true }));
  await page.goto('./');
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
  await page.getByRole('button', { name: 'Toggle Theme' }).click();
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'light');
});
