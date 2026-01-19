# App Store Compliance Strategy 🛡️

## Objective
Ensure "Earn Your Vices" fully complies with **App Store Review Guideline 1.4.3**, which states:
> Apps that encourage consumption of ... excessive amounts of alcohol are not permitted. Apps that encourage minors to consume any of these substances will be rejected.

## Risk Assessment
The concept "Earn Your Vices" inherently risks scrutiny because it gamifies the acquisition of alcohol.
*   **High Risk**: If the app implies "You ran 10km, go drink 2 pints *right now*."
*   **High Risk**: If the app allows banking unlimited alcohol credits (e.g., "You have 50 pints banked!").
*   **High Risk**: If the app targets minors (e.g., "Candy & Beer").

## Mitigation Strategy: The "Passthrough" Defense �️

By adopting the **Emoji Freedom** model, we shift the app from being a "drinking game" to a "neutral tracking utility".

### 1. Safe Defaults (The "Pizza Defense") �
*   **Action**: The app MUST install with a safe, family-friendly default (e.g., "Pizza �").
*   **Reviewer Experience**: When an App Store reviewer opens the app, they see a fun fitness app for earning slices. There is NO reference to alcohol.
*   **Validation**: This proves the app's *intent* is fitness motivation, not alcohol promotion.

### 2. User-Generated Context (The "Not Our Words") 🗣️
*   **Action**: If a user *chooses* to rename their reward to "Beer 🍺", that is user-generated content/settings.
*   **Precedent**: Calorie trackers allow users to log "Vodka", but the app isn't "encouraging" vodka consumption; it's tracking user behavior.
*   **Benefit**: No Age Verification needed.

### 3. Neutral Terminology ⚖️
*   **Action**: We track "Credits" or "Points".
*   **Action**: Avoid "Binge" mechanics.

## Implementation Checklist
- [ ] Implement `ViceSettings` (Default: Pizza 🍕).
- [ ] Ensure "Alcohol" is never hardcoded in the UI.
