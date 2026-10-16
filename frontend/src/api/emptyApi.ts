import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

// initialize an empty api service that we'll inject endpoints into later as needed
export const emptySplitApi = createApi({
  // The app is served under a prefix (vite `base`), so the API is too: `/earnyourbeers/api/...`.
  baseQuery: fetchBaseQuery({
    baseUrl: import.meta.env.BASE_URL,
    // The session is an HTTP-only cookie (BEH-AUTH-1): always send it.
    credentials: 'include',
  }),
  tagTypes: ['Session', 'Dashboard'],
  endpoints: () => ({}),
});
