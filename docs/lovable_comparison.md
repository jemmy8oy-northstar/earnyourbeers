# UX Analysis: Lovable Reference vs. Earn Your Vices 🔍

I've analyzed the media provided of the partner's app built on Lovable. Here is a breakdown of the differences in behavior, UX, and terminology compared to our current implementation.

## Visual Hierarchy & Dashboard

### Lovable App
![Dashboard Window](/Users/jamesbalenthiran/.gemini/antigravity/brain/66ef8222-07c8-4975-a653-50bef1186344/uploaded_image_0_1769104068722.jpg)

- **Card-Centric**: Uses distinct, high-contrast cards for "Balance", "Beers Consumed", and "Activity".
- **Visual Progress**: The "Current Balance" card features a primary horizontal progress bar that clearly visualizes the "safety margin" between activity and vice.
- **Micro-Metrics**: Shows "Offset" (Earned) and "Beers" (Spent) as small secondary labels directly on the balance card.
- **Action focus**: Large +/- buttons on the "Beers Consumed" card for quick entry.

### Earn Your Vices (Current)
- **Status-First**: Focuses heavily on the **Tier/Rank** and the "Net Points" balance.
- **Multi-Discipline**: Our activity cards are discipline-aware (Run/Cycle/Swim), whereas the reference seems focused on a single "Offset" pool.

---

## Terminology

| Concept | Lovable Reference | Earn Your Vices |
| :--- | :--- | :--- |
| **Earnings** | "Offset" | "Points" / "Work" |
| **Spending** | "Beers" | "Pints" / "Vices" |
| **Status** | "Balance" | "League Balance" |

---

## Behavioral Differences

### 1. The Settlement Flow
![Weekly Balance Summary](/Users/jamesbalenthiran/.gemini/antigravity/brain/66ef8222-07c8-4975-a653-50bef1186344/uploaded_image_1_1769104068722.jpg)

- **Lovable**: Features a dedicated **"Weekly Balance"** summary screen. 
  - It uses a clear "VS" layout (e.g., *5 Beers vs 7 Offset*).
  - High emotional reward: Shows a trophy icon and "Great job!" text.
  - Manual Reset: Includes a **"Start New Week"** button, implying an explicit user-triggered reset.
- **Earn Your Vices**: Uses the **"Weekly Settlement"** scanner.
  - Our flow is more "RPG-like"—it determines if you get promoted or demoted based on performance.
  - Automatic Reset: Currently handles settlement on a weekly cycle (Mondays) rather than a manual button.

### 2. The Feedback Loop
- **Lovable**: The "+2" green balance on the summary screen is the primary celebratory metric.
- **Earn Your Vices**: Our primary "win" is hitting the **Next Tier** or gaining **Prestige**.

---

## Inspiration Points for Us
- **"Offset" Terminology**: This is a very clear word for non-technical users to understand "working off" a beer.
- **Celebratory Summary**: The Trophy/Trophy-Screen is a great way to mark the end of a week. We could integrate this more heavily into our "Analyzing Performance" reveal.
- **The "VS" Logic**: Explaining the balance as "Work done vs. Vices had" is more intuitive than just a single point number.
