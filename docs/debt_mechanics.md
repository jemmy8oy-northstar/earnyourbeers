# Feature Deep Dive: Pint Debt & Clearing

## The "Pint Debt" Concept
The app tracks a **Lifetime Pint Balance**. 
Every drink adds to the debt (negative balance), every activity earns pints (positive credit).

### UI Representation
- A **Primary Weekly Counter** showing pints earned vs consumed this week.
- A **Secondary Lifetime Balance** showing your all-time standing.

## "Clearing Debt" Mechanism
- **The Celebration**: You can "Clear Debt" once your lifetime balance returns to **0 or higher**. 
- **The Reward**: Rolling over into a positive balance grants "Beer Credits" which can be used to purchase "Free Drinks" in the app (purely cosmetic logging).

## Metrics to Track
1.  **Weekly Pint Balance**: (Pints Earned This Week - Pints Consumed This Week).
2.  **Lifetime Pint Balance**: All-time net total.
3.  **Times Debt Cleared**: Counter of successful returns to zero.
4.  **Days Since Last Debt**: Streak of keeping the balance >= 0.
