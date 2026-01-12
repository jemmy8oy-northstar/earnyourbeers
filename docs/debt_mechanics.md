# Feature Deep Dive: Pint Debt & Clearing

## The "Pint Debt" Concept
The app tracks a **Lifetime Pint Balance**. 
Every drink adds to the debt (negative balance), every activity earns pints (positive credit).

### UI Representation
- A **Primary Weekly Counter** showing pints earned vs consumed this week.
- A **Secondary Lifetime Balance** showing your all-time standing.

## "Bottled It" (Automatic Rescue)
- **The Floor**: If you hit your debt limit, you've officially "Bottled It."
- **The Consequence**: One bottle (50 pints) is deducted from your Vault to pay off the debt, and you are demoted.
- **The Outcome**: You start at 0.0 in the lower league, ready to try again.

## Metrics to Track
1.  **Weekly Pint Balance**: (Pints Earned This Week - Pints Consumed This Week).
2.  **Lifetime Pint Balance**: All-time net total.
3.  **Times Debt Cleared**: Counter of successful returns to zero.
4.  **Days Since Last Debt**: Streak of keeping the balance >= 0.
