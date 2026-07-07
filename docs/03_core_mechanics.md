# Core Mechanics

The `lib/core/` directory contains the fundamental business logic and state engines that power Purrist.

## 1. The Moody Cat Engine (`mood_engine`)
This is the heart of the gamification loop. The home screen features a virtual feline whose state is directly mapped to the user's health metrics.

### State Transitions
The engine evaluates data on app startup and during background polling:
- **Ecstatic (Zoomies):** Triggered when the `health` module reports > 10,000 steps.
- **Angry / Lethargic:** Triggered when the `usage_stats` module reports screen time > 3 hours. The cat actively turns its back on the user.
- **Sympathetic:** Triggered if the user logs a poor mood in the `journal` module. The AI system prompt is updated to be comforting rather than judgmental.

## 2. Health & Telemetry Sensors (`health`)
Because Apple's HealthKit and iOS sandbox restrict background screen time polling without MDM enterprise profiles, Purrist relies heavily on native Android APIs.

- **usage_stats API:** Grants granular, background metrics on the user's doomscrolling habits. Used to calculate the "Cat Nap" countdown bar.
- **health API:** Processes physical activity data (pedometer step counting) to feed into the Moody Cat Engine.

## 3. The Economy Engine (`economy`)
What good is a digital pet if you can't spoil it? The economy module governs the "Treats" currency.

### Earning Treats
The economy loop incentivizes daily health habits. Users earn treats by:
1. **Hunting Prey (Scratchpad Tasks):** Completing a task instantly grants treats.
2. **Daily Vibe Check:** Logging daily emotions in the journal.
3. **Cat Nap Mastery:** Keeping daily screen time under the 3-hour limit.

### Meow Mart
Users spend treats in the Meow Mart to purchase cosmetic upgrades. This provides a long-term progression system to ensure high user retention long after the novelty of the AI chat wears off.
State for inventory and wallet balances is highly cached in `SharedPreferences`.

## 4. Streaks & Persistence (`streak`)
A lightweight sub-engine that tracks consecutive days of task completion and healthy screentime limits. Broken streaks result in a significantly harsher response from the AI companion upon the next login.
