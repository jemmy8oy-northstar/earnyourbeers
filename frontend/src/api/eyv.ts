import { enhancedApi } from './generatedApi';

/**
 * The generated client (generatedApi.ts, from openapi.json) types every response as `unknown`,
 * because the backend's routes declare no response schemas. This file adds the two things the
 * generated one cannot: cache tags (so a log/dismiss/sign-in refreshes what is on screen) and the
 * response shapes, mirrored from backend/…WebApi/Routes/*Response.cs.
 */

export interface Account { username: string }

export interface League {
  level: number;
  tier: string;
  division: string;
  /** −25…+25 */
  tally: number;
  /** 0…1, the bar's fill */
  tallyProgress: number;
  difficulty: number;
}

export interface Entry {
  id: string;
  kind: 'Vice' | 'Activity' | string;
  /** "Run" | "Cycle" | "Swim", null for a vice */
  activity: 'Run' | 'Cycle' | 'Swim' | null;
  amount: number;
  loggedAt: string;
  editable: boolean;
}

export interface Week {
  /** 0 = this week, −1 = last week … */
  offset: number;
  start: string;
  balance: number;
  entries: Entry[];
  hasEarlier: boolean;
}

export type SettlementOutcome = 'PositionSecured' | 'Promoted' | 'DoublePromotion' | 'Demoted';

export interface Settlement { weeklyNet: number; outcome: SettlementOutcome }

export interface Dashboard {
  onboarded: boolean;
  viceEmoji: string;
  league: League;
  /** Points one unit earns at the current tier, keyed "Run" | "Cycle" | "Swim". */
  pointsPerUnit: Record<string, number>;
  week: Week;
  settlement: Settlement | null;
}

const session = ['Session', 'Dashboard'] as const;

export const eyvApi = enhancedApi.enhanceEndpoints({
  endpoints: {
    me: { providesTags: ['Session'] },
    getDashboard: { providesTags: ['Dashboard'] },
    login: { invalidatesTags: [...session] },
    register: { invalidatesTags: [...session] },
    logout: { invalidatesTags: [...session] },
    logActivity: { invalidatesTags: ['Dashboard'] },
    logVice: { invalidatesTags: ['Dashboard'] },
    editEntry: { invalidatesTags: ['Dashboard'] },
    deleteEntry: { invalidatesTags: ['Dashboard'] },
    dismissSettlement: { invalidatesTags: ['Dashboard'] },
    onboard: { invalidatesTags: ['Dashboard'] },
    changeVice: { invalidatesTags: ['Dashboard'] },
    resetProfile: { invalidatesTags: ['Dashboard'] },
  },
});

export const {
  useLoginMutation,
  useRegisterMutation,
  useLogoutMutation,
  useLogActivityMutation,
  useLogViceMutation,
  useEditEntryMutation,
  useDeleteEntryMutation,
  useDismissSettlementMutation,
  useOnboardMutation,
  useChangeViceMutation,
  useResetProfileMutation,
} = eyvApi;

/** Typed wrapper: the signed-in account, or undefined while loading / signed out. */
export function useSession() {
  const r = eyvApi.useMeQuery();
  // RTK keeps the last good `data` after a later refetch fails; a failed /me (401 after sign-out)
  // must mean "no account", not the stale one.
  return { ...r, account: r.isError ? undefined : (r.data as Account | undefined) };
}

/** Typed wrapper: the dashboard for a week offset (0 = this week, −1 = last week …). */
export function useDashboard(week: number) {
  const r = eyvApi.useGetDashboardQuery({ week });
  return { ...r, dashboard: r.data as Dashboard | undefined };
}

/** The human message of a failed request: ProblemDetails.detail when the API sent one. */
export function errorMessage(error: unknown, fallback = 'Something went wrong. Please try again.'): string {
  const e = error as { data?: { detail?: unknown }; status?: unknown } | undefined;
  if (e?.data && typeof e.data.detail === 'string' && e.data.detail) return e.data.detail;
  if (e?.status === 'FETCH_ERROR') return 'Could not reach the server.';
  return fallback;
}
