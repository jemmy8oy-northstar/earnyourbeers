# Feature Deep Dive: KM Debt & Clearing

## The "KM Debt" Concept
Instead of just a daily balance, the app tracks a **Lifetime KM Debt**. 
Every drink adds to the debt, every activity subtracts from it.

### UI Representation
- A giant "Debt Meter" on the dashboard.
- Red color for "In Debt" (Negative Balance).
- Green/Gold color for "In Credit" (Positive Balance).

## "Clearing Debt" Mechanism
Clearing debt can work in two ways. I suggest **System B** for more "fun":

- **Option A (Manual Reset)**: You hit a button to set debt to zero. This is cheating!
- **Option B (The Celebration)**: You can only "Clear Debt" when your balance hits **0 or higher**. 
- **The Counter**: Once you hit >= 0, you can "Verify & Clear". This increments your "Times Cleared" count and resets your "Days Since Debt Cleared" streak.

## Metrics to Track
1.  **Current KM Balance**: (Running Total of Activities - Running Total of Drinks).
2.  **Debt Cleared Count**: How many times you've successfully returned to a zero balance.
3.  **Days Since Last Cleared**: A streak-like metric. "It has been 12 days since you were last in Beer Debt."
4.  **Longest 'Clean' Streak**: The record for the above.
