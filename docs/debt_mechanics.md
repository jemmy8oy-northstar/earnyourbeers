# Feature Deep Dive: Pint Debt & Clearing

## The "Pint Debt" Concept
The app tracks a **Lifetime Pint Balance**. 
Every drink adds to the debt (negative balance), every activity earns pints (positive credit).

### UI Representation
- A **Primary Weekly Counter** showing pints earned vs consumed this week.
- A **Secondary Lifetime Balance** showing your all-time standing.

## The Weekly Settlement
- **Current Week**: The dashboard shows a "live" count for the current 7-day period.
- **Monday Reset**: At the end of the week, the balance "Settles". 
- **The Floor**: If the settlement brings you below your Debt Floor, you are officially **"Tapped Out."**

## Metrics to Track
1.  **Weekly Pint Balance**: (Pints Earned This Week - Pints Consumed This Week).
2.  **Lifetime Pint Balance**: All-time net total.
3.  **Times Debt Cleared**: Counter of successful returns to zero.
4.  **Days Since Last Debt**: Streak of keeping the balance >= 0.
