# Feature Breakdown

The `lib/features/` directory contains the specific, user-facing modules of Purrist. Each feature relies on the `core/` engines to function.

## 1. Auth (`features/auth`)
The entry point of the app. Handles Firebase Email/Password and Google OAuth.
- **Key Detail:** We removed early "developer bypasses" to enforce strict authentication flows.
- **Error Handling:** Raw stack traces (`LateInitializationError`) were replaced with graceful, user-friendly UI dialogues, ensuring a polished experience even when network conditions fail.

## 2. The Scratchpad (`features/tasks`)
A highly opinionated task manager designed to cut through procrastination.
- **Philosophy:** Tasks are not "todos"; they are **Prey**. You don't just "complete" a task; you *hunt it down*.
- **UI:** Brutalist styling with harsh checkboxes. Completing a task triggers a burst of Neobrutalist UI micro-animations (confetti, screen shake) and instantly rewards Treats.

## 3. The LLaMA 3 Chat (`features/chat`)
The interactive terminal with your sassy virtual companion.
- **Prompt Injection:** When the user sends a message, the frontend intercepts the request and injects a hidden system block containing the user's step count, screen time, and current task completion rate.
- **Persona:** The LLaMA 3 70B model is instructed to behave like a snarky, deeply judgmental cat. If the user complains about being tired, and the system prompt indicates 4 hours of screen time, the cat will actively roast the user for doomscrolling.
- **Execution:** Streaming responses from the Groq API provide the illusion of real-time typing.

## 4. Home Screen & Navigation (`features/home`, `features/navigation`)
The primary dashboard.
- Displays the Rive/Lottie animation of the Moody Cat based on the state calculated by the `mood_engine`.

## 5. Secondary Features
- **Challenges (`features/challenges`):** Long-term goals (e.g., "Keep screentime under 2 hours for 5 days") that grant massive Treat payouts.
- **Focus / Relief (`features/focus`, `features/relief`):** Pomodoro timers and guided breathing exercises, utilizing Neobrutalist micro-interactions to retain attention.
