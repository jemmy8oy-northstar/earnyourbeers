/** Display helpers, ported from the Flutter dashboard (lib/ui/screens/dashboard_screen.dart). */

/** BEH-BALANCE-1: two decimals. `-0` and tiny negatives that round to zero print as 0.00. */
export function formatBalance(balance: number): string {
  const s = balance.toFixed(2);
  return s === '-0.00' ? '0.00' : s;
}

/** BEH-BALANCE-1: SQUARE is exactly 0. */
export function balanceLabel(balance: number): 'POINTS IN CREDIT' | 'POINTS IN DEBT' | 'SQUARE' {
  if (balance > 0) return 'POINTS IN CREDIT';
  if (balance < 0) return 'POINTS IN DEBT';
  return 'SQUARE';
}

/** BEH-HISTORY-1: CURRENT WEEK, or WEEK OF d/m (no zero padding) from the week's start. */
export function weekHeader(offset: number, start: string): string {
  if (offset === 0) return 'CURRENT WEEK';
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(start);
  if (!m) return 'PAST WEEK';
  return `WEEK OF ${Number(m[3])}/${Number(m[2])}`;
}

/** The API sends UTC instants; a value with no zone is UTC, not local. */
function parseInstant(iso: string): Date {
  return new Date(/(Z|[+-]\d{2}:?\d{2})$/.test(iso) ? iso : `${iso}Z`);
}

/** BEH-HISTORY-1: "Logged at H:MM" in the viewer's local time. */
export function loggedAt(iso: string): string {
  const d = parseInstant(iso);
  return `Logged at ${d.getHours()}:${String(d.getMinutes()).padStart(2, '0')}`;
}

/** Whole numbers bare, otherwise one decimal (as the Flutter log tiles do). */
export function formatAmount(amount: number): string {
  return Number.isInteger(amount) ? String(amount) : amount.toFixed(1);
}

/** Points one unit earns, e.g. +0.5 / +0.17. */
export function formatPoints(points: number): string {
  return `+${Number.isInteger(points) ? points : points.toFixed(2)}`;
}

export const ACTIVITY_UNIT: Record<string, string> = { Run: 'km', Cycle: 'km', Swim: 'lengths' };
