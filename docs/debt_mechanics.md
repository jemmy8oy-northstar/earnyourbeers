# Feature Deep Dive: Pint Debt & Clearing

## The "Pint Debt" Concept
The app tracks a **Lifetime Pint Balance**. 
Every drink adds to the debt (negative balance), every activity earns pints (positive credit).

### UI Representation
- A **Primary Weekly Counter** showing pints earned vs consumed this week.
- A **Secondary Lifetime Balance** showing your all-time standing.

## "Clearing Debt" Mechanism (Debt Mercy)
- **The Mercy Rule**: While your lifetime balance is negative, activity earning rates stay at the **Base Level** (1.0x).
- **The Celebration**: You can "Clear Debt" once your balance returns to **0**. 
- **The Flex**: Once you "Clear Debt" and move into credit, your League's **Challenge Multiplier** activates, making it harder to earn more.

## Metrics to Track
1.  **Weekly Pint Balance**: (Pints Earned This Week - Pints Consumed This Week).
2.  **Lifetime Pint Balance**: All-time net total.
3.  **Times Debt Cleared**: Counter of successful returns to zero.
4.  **Days Since Last Debt**: Streak of keeping the balance >= 0.
