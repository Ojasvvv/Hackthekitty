# UI & Design System

The visual identity of Purrist is built entirely around **Neobrutalism**. This is not just an aesthetic choice; it is a core functional requirement to combat notification fatigue and user apathy.

## The Problem with Material Design
Material 3 and Apple's HIG focus on softness, subtle shadows, and blending into the background. While excellent for utility apps, they fail at gamification because they do not draw the eye or trigger emotional responses. A flat, grey button does not release dopamine when pressed.

## The Purrist Neobrutalist System
Every widget in the `lib/` directory was custom-built or heavily modified to adhere to the following rules:

### 1. Harsh Borders
We eschew soft drop shadows in favor of solid, thick black borders (`Border.all(color: Colors.black, width: 3)`). 

### 2. High Contrast Colors
The palette utilizes highly saturated, unapologetic colors (neon yellows, bright pinks, stark whites) against solid black lines. This guarantees high visibility and visual excitement.

### 3. Hard Shadows
Instead of Gaussian blurs, our shadows are solid, offset blocks of color. 
Example Implementation:
```dart
BoxDecoration(
  color: Colors.white,
  border: Border.all(color: Colors.black, width: 3),
  boxShadow: const [
    BoxShadow(
      color: Colors.black,
      offset: Offset(4, 4),
      blurRadius: 0, // CRITICAL: No blur!
    ),
  ],
)
```
This grounds the UI elements physically, making the app feel like a tangible, interactive toy rather than a flat piece of glass.

### 4. Typography
We utilize modern, bold Google Fonts (primarily **Outfit** and **Inter**). Headings are large and heavily weighted, ensuring maximum legibility and contributing to the "loud" aesthetic.

## 5. Micro-Animations & Rive/Lottie
Because the UI relies on hard edges, the movement within the app provides the necessary fluidity to feel premium.
- **Rive & Lottie:** The Moody Cat itself is animated using Rive/Lottie files, allowing complex, state-driven animations (e.g., smoothly transitioning from sleeping to the "Zoomies") without bogging down the Flutter main thread.
- **Micro-interactions:** Tapping the "Click me!" tooltip or completing a Scratchpad task triggers localized physics-based animations (confetti pops, screen shakes). These are the critical dopamine hits that reinforce the gamified loop.
