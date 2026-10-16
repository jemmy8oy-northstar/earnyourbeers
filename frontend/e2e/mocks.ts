import type { Page, Route } from '@playwright/test';

/**
 * Deterministic API mocks for the e2e suite: a tiny in-memory stand-in for the backend
 * (AuthRoutes, DashboardRoutes). Nothing touches a real server, and the response shapes mirror
 * backend/…WebApi/Routes/*Response.cs. Add a route here whenever the frontend calls a new one.
 *
 * Scoring is simplified to difficulty 1 so the numbers are easy to read in assertions:
 * Run 0.5/km, Cycle 1/6 per km, Swim 1/60 per length, a vice unit costs 1.
 */

export interface MockEntry {
  id: string;
  kind: 'Activity' | 'Vice';
  activity: 'Run' | 'Cycle' | 'Swim' | null;
  amount: number;
  loggedAt: string;
}

export interface MockState {
  signedIn: boolean;
  /** Set for the sign-in test: the only credentials the fake accepts. */
  validUser: { username: string; password: string };
  onboarded: boolean;
  settlement: { weeklyNet: number; outcome: string } | null;
  entries: MockEntry[];
  /** Entries of earlier weeks, by offset (−1, −2 …). */
  history: Record<number, MockEntry[]>;
  /** Every request the fake received, "METHOD /path", for assertions. */
  calls: string[];
}

const PER_UNIT = { Run: 0.5, Cycle: 1 / 6, Swim: 1 / 60 } as const;

export const fixedEntry = (id: string, kind: MockEntry['kind'], activity: MockEntry['activity'], amount: number, loggedAt: string): MockEntry =>
  ({ id, kind, activity, amount, loggedAt });

export function newState(overrides: Partial<MockState> = {}): MockState {
  return {
    signedIn: false,
    validUser: { username: 'james', password: 'correct horse' },
    onboarded: true,
    settlement: null,
    entries: [],
    history: {},
    calls: [],
    ...overrides,
  };
}

function balance(entries: MockEntry[]): number {
  return entries.reduce(
    (sum, e) => sum + (e.kind === 'Vice' ? -e.amount : e.amount * PER_UNIT[e.activity!]),
    0,
  );
}

function monday(offset: number): string {
  // 2026-10-12 is a Monday; one week back per step.
  const d = new Date(Date.UTC(2026, 9, 12 + 7 * offset));
  return d.toISOString().slice(0, 19);
}

function dashboard(s: MockState, offset: number) {
  const list = offset === 0 ? s.entries : (s.history[offset] ?? []);
  const sorted = [...list].sort((a, b) => b.loggedAt.localeCompare(a.loggedAt));
  const earliest = Math.min(0, ...Object.keys(s.history).map(Number));
  return {
    onboarded: s.onboarded,
    viceEmoji: '🍺',
    league: { level: 3, tier: 'Bronze', division: 'Division 4', tally: 4.5, tallyProgress: 0.59, difficulty: 1 },
    pointsPerUnit: { Run: PER_UNIT.Run, Cycle: PER_UNIT.Cycle, Swim: PER_UNIT.Swim },
    week: {
      offset,
      start: monday(offset),
      balance: balance(list),
      entries: sorted.map((e, i) => ({ ...e, editable: offset === 0 && i === 0 })),
      hasEarlier: offset > earliest,
    },
    settlement: s.settlement,
  };
}

/** Wire the fake backend into the page. Returns its state so a test can seed and inspect it. */
export async function mockApi(page: Page, state: MockState = newState()): Promise<MockState> {
  const reply = (route: Route, status: number, json?: unknown) =>
    route.fulfill(json === undefined ? { status } : { status, json });
  const body = (route: Route) => route.request().postDataJSON() as Record<string, unknown>;
  let seq = 0;
  const stamp = () => `2026-10-15T09:${String(10 + seq++).padStart(2, '0')}:00Z`;

  await page.route('**/earnyourbeers/api/**', async (route) => {
    const req = route.request();
    const path = new URL(req.url()).pathname.replace(/^.*?\/api/, '/api');
    state.calls.push(`${req.method()} ${path}`);
    const m = req.method();

    if (path === '/api/status') return reply(route, 200, { status: 'Healthy' });

    if (path === '/api/auth/me') {
      return state.signedIn ? reply(route, 200, { username: state.validUser.username }) : reply(route, 401);
    }
    if (path === '/api/auth/login' && m === 'POST') {
      const b = body(route);
      if (b.username === state.validUser.username && b.password === state.validUser.password) {
        state.signedIn = true;
        return reply(route, 200, { username: state.validUser.username });
      }
      return reply(route, 401, { title: 'Not authenticated', status: 401, detail: 'Wrong username or password.' });
    }
    if (path === '/api/auth/register' && m === 'POST') {
      const b = body(route);
      if (b.username === state.validUser.username) {
        return reply(route, 409, { title: 'Conflict', status: 409, detail: 'That username is taken.' });
      }
      state.signedIn = true;
      state.validUser = { username: String(b.username), password: String(b.password) };
      state.onboarded = false;
      return reply(route, 201, { username: String(b.username) });
    }
    if (path === '/api/auth/logout' && m === 'POST') {
      state.signedIn = false;
      return reply(route, 204);
    }

    if (!state.signedIn) return reply(route, 401);

    if (path === '/api/dashboard') {
      const week = Number(new URL(req.url()).searchParams.get('week') ?? 0);
      return reply(route, 200, dashboard(state, Math.min(0, week)));
    }
    if (path === '/api/settlement/dismiss' && m === 'POST') {
      state.settlement = null;
      return reply(route, 204);
    }
    if (path === '/api/log/activity' && m === 'POST') {
      const b = body(route);
      const e = fixedEntry(`e-${seq}`, 'Activity', b.type as MockEntry['activity'], Number(b.amount), stamp());
      state.entries.push(e);
      return reply(route, 200, { ...e, editable: true });
    }
    if (path === '/api/log/vice' && m === 'POST') {
      const e = fixedEntry(`e-${seq}`, 'Vice', null, Number(body(route).amount), stamp());
      state.entries.push(e);
      return reply(route, 200, { ...e, editable: true });
    }
    const entry = /^\/api\/log\/([^/]+)$/.exec(path);
    if (entry && m === 'PUT') {
      const e = state.entries.find((x) => x.id === entry[1]);
      if (!e) return reply(route, 404);
      e.amount = Number(body(route).amount);
      return reply(route, 200, { ...e, editable: true });
    }
    if (entry && m === 'DELETE') {
      state.entries = state.entries.filter((x) => x.id !== entry[1]);
      return reply(route, 204);
    }
    return reply(route, 404);
  });

  return state;
}
