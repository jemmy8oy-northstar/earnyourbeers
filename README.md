# Earn Your Beers 🍻🏃‍♂️

> **A web app (earnyourbeers#1):** a React frontend (`frontend/`) on a .NET backend (`backend/`),
> scaffolded from web-template. Its spec lives in Kit (`earnyourbeers.beh`). The original Flutter
> app was retired once the web app matched it; it remains in git history.

A fun fitness-tracking application designed to help users "offset" their drinks through physical activity.

## Core Concept
The goal is to provide a simple way to track drinks and activities with a "conversion" system.

- **Drink Logging**: Record when you have a drink.
- **Activity Logging**: Record physical activities like running or cycling.
- **Conversion Logic**: A system that equates activities to drinks.
    - *Example*: 1 Pint = 5km Run or 20km Cycle.
- **Progress Tracking**: A dashboard showing the "balance"—how many drinks have been earned or how much exercise is needed to "pay off" a current balance.

## Development Roadmap

### Phase 1: Database & Logic Design
- User Profiles: Basic setup for users to save their data.
- Activity/Drink Schema: Define data points (date, type, distance/duration).
- Conversion Table: Configurable set of "costs."

### Phase 2: MVP Development (Current)
- Frontend: React web app (formerly Flutter).
- Manual Input: Manual entry for stats.
- Simple UI: Clean and intuitive dashboard.

### Phase 3: Integration (Future)
- Wearable Sync: Integration with APIs (Garmin, Strava, Apple Health).

## Project Structure
- `backend/`: .NET API (auth, logging, scoring, league).
- `frontend/`: React web app.
- `helm/`: deployment chart.
- `docs/`: Project documentation and deep dives.
- `.antigravity/`: AI context and instructions.

## Getting Started
See `CLAUDE.md` → *Running Locally*: `dotnet run` the WebApi in `backend/`, then
`npm run dev` in `frontend/`.

---
*Inspired by a [YouTube video](https://www.youtube.com/watch?v=gPzL90ZtClA).*
