import { emptySplitApi as api } from "./emptyApi";
const injectedRtkApi = api.injectEndpoints({
  endpoints: (build) => ({
    getStatus: build.query<GetStatusApiResponse, GetStatusApiArg>({
      query: () => ({ url: `/api/status` }),
    }),
    register: build.mutation<RegisterApiResponse, RegisterApiArg>({
      query: (queryArg) => ({
        url: `/api/auth/register`,
        method: "POST",
        body: queryArg.credentials,
      }),
    }),
    login: build.mutation<LoginApiResponse, LoginApiArg>({
      query: (queryArg) => ({
        url: `/api/auth/login`,
        method: "POST",
        body: queryArg.credentials,
      }),
    }),
    logout: build.mutation<LogoutApiResponse, LogoutApiArg>({
      query: () => ({ url: `/api/auth/logout`, method: "POST" }),
    }),
    me: build.query<MeApiResponse, MeApiArg>({
      query: () => ({ url: `/api/auth/me` }),
    }),
    getDashboard: build.query<GetDashboardApiResponse, GetDashboardApiArg>({
      query: (queryArg) => ({
        url: `/api/dashboard`,
        params: {
          week: queryArg.week,
        },
      }),
    }),
    dismissSettlement: build.mutation<
      DismissSettlementApiResponse,
      DismissSettlementApiArg
    >({
      query: () => ({ url: `/api/settlement/dismiss`, method: "POST" }),
    }),
    logActivity: build.mutation<LogActivityApiResponse, LogActivityApiArg>({
      query: (queryArg) => ({
        url: `/api/log/activity`,
        method: "POST",
        body: queryArg.activityRequest,
      }),
    }),
    logVice: build.mutation<LogViceApiResponse, LogViceApiArg>({
      query: (queryArg) => ({
        url: `/api/log/vice`,
        method: "POST",
        body: queryArg.amountRequest,
      }),
    }),
    editEntry: build.mutation<EditEntryApiResponse, EditEntryApiArg>({
      query: (queryArg) => ({
        url: `/api/log/${queryArg.id}`,
        method: "PUT",
        body: queryArg.amountRequest,
      }),
    }),
    deleteEntry: build.mutation<DeleteEntryApiResponse, DeleteEntryApiArg>({
      query: (queryArg) => ({
        url: `/api/log/${queryArg.id}`,
        method: "DELETE",
      }),
    }),
  }),
  overrideExisting: false,
});
export { injectedRtkApi as enhancedApi };
export type GetStatusApiResponse = unknown;
export type GetStatusApiArg = void;
export type RegisterApiResponse = unknown;
export type RegisterApiArg = {
  credentials: Credentials;
};
export type LoginApiResponse = unknown;
export type LoginApiArg = {
  credentials: Credentials;
};
export type LogoutApiResponse = unknown;
export type LogoutApiArg = void;
export type MeApiResponse = unknown;
export type MeApiArg = void;
export type GetDashboardApiResponse = unknown;
export type GetDashboardApiArg = {
  week?: number | string;
};
export type DismissSettlementApiResponse = unknown;
export type DismissSettlementApiArg = void;
export type LogActivityApiResponse = unknown;
export type LogActivityApiArg = {
  activityRequest: ActivityRequest;
};
export type LogViceApiResponse = unknown;
export type LogViceApiArg = {
  amountRequest: AmountRequest;
};
export type EditEntryApiResponse = unknown;
export type EditEntryApiArg = {
  id: string;
  amountRequest: AmountRequest;
};
export type DeleteEntryApiResponse = unknown;
export type DeleteEntryApiArg = {
  id: string;
};
export type Credentials = {
  username: string;
  password: string;
};
export type ActivityType = "Run" | "Cycle" | "Swim";
export type ActivityRequest = {
  type: ActivityType;
  amount: number | string;
};
export type AmountRequest = {
  amount: number | string;
};
export const {
  useGetStatusQuery,
  useRegisterMutation,
  useLoginMutation,
  useLogoutMutation,
  useMeQuery,
  useGetDashboardQuery,
  useDismissSettlementMutation,
  useLogActivityMutation,
  useLogViceMutation,
  useEditEntryMutation,
  useDeleteEntryMutation,
} = injectedRtkApi;
