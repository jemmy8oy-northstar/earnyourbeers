# App Store Compliance Strategy 🛡️

## Objective
Ensure "Earn Your Vices" fully complies with **App Store Review Guideline 1.4.3**, which states:
> Apps that encourage consumption of ... excessive amounts of alcohol are not permitted. Apps that encourage minors to consume any of these substances will be rejected.

## Risk Assessment
The concept "Earn Your Vices" inherently risks scrutiny because it gamifies the acquisition of alcohol.
*   **High Risk**: If the app implies "You ran 10km, go drink 2 pints *right now*."
*   **High Risk**: If the app allows banking unlimited alcohol credits (e.g., "You have 50 pints banked!").
*   **High Risk**: If the app targets minors (e.g., "Candy & Beer").

## Mitigation Strategy

### 1. The "Responsible Cap" (Hard Limit) 🛑
We will implement a hard limit on the amount of Alcohol units that can be displayed or redeemable in a standard week, aligning with health guidelines (e.g., CDC/NHS guidelines of ~14 units/week).
*   **Action**: If a user runs 100km (20 pints), the UI limits the "Liquid Vice" view to a safe cap (e.g., 7 pints/week) and converts the overflow to "General Points" or locks it.
*   **Messaging**: "Whoa! You've earned plenty. Drink responsibly. Excess points bank for next week."

### 2. Explicit Age Gating 🔞
*   **Action**: Onboarding MUST ask "Are you over legal drinking age?" before showing any Alcohol options.
*   **Result**: If "No", the "Liquid Vices" category is strictly hidden.

### 3. Neutralizing the "Binge" Incentive 🧘
*   **Action**: Avoid "Streak" mechanics for alcohol.
*   **Action**: Rename "Redeem" button to "Log Enjoyment" or "Track", reducing the pressure to consume.
*   **Action**: Add a permanent disclaimer in the Settings/About page citing medical advice.

### 4. Default to Non-Alcohol 🎮
*   **Action**: As planned, the default Vice is **Gaming** or **Food**. Alcohol requires active opt-in. This demonstrates the app is primarily about *balance*, not *drinking*.

## Implementation Checklist
- [ ] Add `AgeVerification` step to Onboarding.
- [ ] Implement `WeeklyAlcoholCap` logic (e.g., max 7 pints visible).
- [ ] Add Disclaimer footer in Settings.
- [ ] Ensure "Liquid Vices" are hidden by default until opted-in.
