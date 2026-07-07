<div align="center">
  <img src="https://media.giphy.com/media/VbnUQpnihPSIgIXuZv/giphy.gif" width="200" alt="Purrist Cat">
  <h1>🐾 Purrist: The Judgmental Wellbeing Companion</h1>
  <p><b>Stop doomscrolling. Start purring. A Neobrutalist approach to digital wellbeing.</b></p>
  
  <p>
    <a href="#-the-problem">The Problem</a> •
    <a href="#-the-solution">The Solution</a> •
    <a href="#-core-features">Features</a> •
    <a href="#-system-architecture">Architecture</a> •
    <a href="#-installation--usage">Installation</a> •
    <a href="#-faq">FAQ</a>
  </p>
</div>

---

> [!CAUTION]
> **⚠️ CRITICAL: ANDROID PERMISSIONS WARNING ⚠️**
> Android 13+ has a security feature called "Restricted Settings" that blocks the required `usage_stats` permission (which we use for screen time tracking). **It blocks this not because Purrist is a virus, but because Android heavily restricts accessibility/usage APIs by default for sideloaded apps.**
>
> **To fix this and allow the app to work:**
> 1. Open Purrist and tap **"Allow Access to Begin"**.
> 2. This opens Android's "Usage Access" settings. Tap on **Purrist**.
> 3. Try to toggle "Permit usage access" on. Android will show a popup saying the app was denied access.
> 4. In that popup, click the text that says **"Learn how to allow access"** (or similar). *(You MUST click this to unlock step 7!)*
> 5. Go to your home screen and long-press the Purrist app icon.
> 6. Tap **App Info** (or the 'i' icon).
> 7. Tap the **three dots** in the top right corner and select **"Allow restricted settings"**.
> 8. Go back into Purrist and tap **"Allow Access to Begin"** again to actually grant the permissions.
> *(Steps may vary slightly between Samsung, Pixel, and other Android devices).*

---

## 🙀 The Problem: Why Digital Wellbeing Apps Fail
The health and wellness app market is saturated with dashboards. When you open a standard screen time or fitness tracker, you are bombarded with lifeless bar charts, pie graphs, and sterile, generic notifications like *"You've been looking at your screen for 4 hours today."* 

**The psychological reality is that nobody cares about a bar chart.** When data is presented in a boring, analytical format, users experience notification fatigue and quickly ignore the metrics. Traditional apps fail because they rely entirely on the user's intrinsic motivation, which is often depleted by the very behaviors (like doomscrolling) the apps are trying to solve.

## 😻 The Solution: Purrist
**What actually motivates people? Emotional connection, gamification, and a little bit of judgment.** 

**Purrist** is a complete paradigm shift. Instead of a dashboard, your health metrics are tied directly to the lifecycle and mood of a virtual 2D cat. If you doomscroll, your cat suffers. If you exercise, your cat thrives. 

By combining **cutting-edge LLaMA 3 AI**, real-time device health metrics, and a stunning, dopamine-inducing **Neobrutalist UI**, Purrist heavily gamifies your mental and physical health, making self-care an addictive, rewarding loop rather than a chore.

---

## 🌟 Core Features & Mechanics

### 😼 1. The Moody Cat Engine
Your home screen is a living, breathing feline companion powered by a complex internal state machine. The cat's mood dynamically shifts based on your real-time health data pulled silently from your device:
- **High Physical Activity**: When the pedometer detects 10,000 steps, the cat becomes ecstatic, plays with digital yarn, and enters a "Zoomies" state.
- **High Screentime**: If you exceed your screen time limits, the cat becomes lethargic, angry, and actively turns its back on you.

### 📜 2. The Scratchpad (Task Management)
A highly opinionated, brutalist task manager designed to cut through procrastination. 
- Tasks aren't "todos"; they are **Prey**. 
- Add your daily goals and *hunt them down*. 
- Completing tasks rewards you instantly with **Treats**, triggering a burst of satisfying Neobrutalist UI micro-animations that reinforce positive behavior.

### 🐟 3. Meow Mart Economy
What good is a digital pet if you can't spoil it? Purrist features a fully integrated virtual economy. 
- Use your hard-earned Treats to buy cosmetic upgrades.
- Unlock new cat colors, hilarious hats, and environmental backgrounds to personalize your companion. 
- This economic loop heavily incentivizes users to complete their health challenges daily to afford premium items.

### 🧠 4. Sassy LLaMA 3 AI Companion
Powered by **Groq**, your cat isn't just a static image. It is an incredibly intelligent, context-aware AI companion. 
- The app automatically injects your real-time health data (screentime, step count, task completion rate) into the AI's hidden system prompt.
- If you chat with the cat after 4 hours of screen time, it will *literally roast you* for being on your phone too much. 
- It has a distinct, snarky, yet ultimately caring personality that makes journaling and self-reflection feel like a conversation with a real friend.

### 💤 5. Cat Nap Challenges & Hydration Tracking
Keep your screentime under 3 hours to fill the "Cat Nap" countdown bar. Drink water to fill your hydration metrics. Every positive action feeds back into the global economy, granting you treats.

---

## 🛠️ System Architecture & Tech Stack

Purrist is built for extreme responsiveness, secure offline-first persistence, and robust identity management. We utilized a modern, serverless architecture to ensure rapid iteration and rock-solid stability during the hackathon.

### 1. The Frontend (Flutter & Riverpod)
- **Framework**: Built in **Flutter**, allowing us to paint stunning, custom Neobrutalist UI components at 60FPS. Every shadow, harsh border, and bold typography choice was meticulously crafted to break away from boring Material Design standards.
- **State Management**: We utilize **Riverpod** for declarative, reactive state management. Repositories automatically rebuild and swap out isolated data when a user changes accounts, ensuring UI consistency without manual `setState` spaghetti.
- **Device Sensors**: We integrate deeply with Android hardware:
  - `usage_stats` API for highly accurate, background screen time tracking.
  - `health` API for pedometer and physical activity data processing.

### 2. Identity & Authentication (Firebase)
- **Firebase Auth**: We utilize Firebase Authentication to support seamless Email/Password and Google OAuth Sign-In. 
- **Multi-Tenant State Isolation**: Because multiple people might use the same device, every user's local data (Chats, Inventory, Tasks) must be strictly isolated. We dynamically prepend the Firebase `uid` to local storage keys. When Riverpod detects an auth state change, it instantly tears down the current providers and rebuilds them with the new user's keys, ensuring complete data separation without requiring a bloated backend database.

### 3. Serverless API & AI (Cloudflare Workers + Groq)
- **Groq API**: Powers the conversational AI, providing sub-millisecond inference speeds for the massive **LLaMA 3 70B** model. This ultra-low latency makes the cat feel genuinely alive and instantly responsive.
- **Cloudflare Workers (Edge Computing)**: *Security is paramount.* We absolutely do not expose our Groq API keys in the Flutter frontend codebase. Instead, we deployed a **Cloudflare Worker** as a blazing-fast, serverless edge proxy. 
  - The Flutter app sends the user's chat prompt and health context to the Cloudflare Worker URL.
  - The Worker securely injects our hidden Groq API key into the headers.
  - The Worker forwards the request to Groq, awaits the LLM stream, and returns the response back to the app. 
  - This architecture ensures 100% protection against API key scraping while maintaining edge-network speeds.

### 4. Local Persistence (SharedPreferences)
To ensure the app works flawlessly offline and loads instantly, all user data, including the entire LLaMA 3 chat history, is heavily cached using `SharedPreferences`.

---

## 🚀 Installation & Usage

Want to experience the sass yourself? We have packaged the app into a fully signed APK for immediate testing.

1. Head over to the [Releases Tab](../../releases) on this GitHub repository.
2. Download the latest `app-release.apk` file to your Android device.
3. Tap the file to install it. *(Note: You may need to enable "Install from Unknown Sources" in your Android settings since it is not on the Play Store yet).*
4. Open **Purrist**, sign up for a new account (you'll instantly receive a **200 Treat signing bonus!**), and start improving your habits!

---

## ❓ FAQ (Frequently Asked Questions)

### Q: Why is this Android only? Why no Apple / iOS version?
**A:** We wanted to build an app that actually holds you accountable. Apple's HealthKit and strict iOS privacy sandboxing completely prohibit global, background screentime tracking unless you are building an enterprise MDM profile or utilizing the heavily restricted ScreenTime API (which requires special entitlements from Apple). To build our "Cat Nap" screen time challenge within this hackathon timeframe, we utilized Android's native `usage_stats` API, which securely grants us exact metrics on your doomscrolling habits. **Apple simply won't let our cat judge you properly!**

### Q: How exactly are Treats calculated?
**A:** The economy is tied to your well-being. There are three main ways to earn:
1. Hunt down (complete) tasks in the Scratchpad.
2. Hit your daily health goals (steps and screen time).
3. Keep your daily screentime under the 3-hour limit to fill up the Cat Nap challenge bar! 

### Q: Is my data safe?
**A:** Absolutely. Privacy is a core tenet of Purrist. We do not store your physical health data, your Scratchpad tasks, or your chat history on any external servers. Everything is saved locally on your device in your isolated account bucket. The only information transmitted over the network is the specific chat prompt sent to our secure Cloudflare Worker for AI processing. 

### Q: What's next on the Roadmap?
**A:** We plan to introduce:
- **Multiplayer / Leaderboards**: Compete with friends to see whose cat is the healthiest.
- **Wearable Integration**: Sync directly with Garmin and Fitbit for more granular heart-rate data to feed the Moody Cat Engine.
- **More AI Personalities**: Unlock different cat personalities (e.g., an overly enthusiastic Golden Retriever persona).

---

<div align="center">
  <h3>Made with 🐟, ☕, and a lot of Sass for the Hackathon</h3>
  <p><i>Because mental health shouldn't be boring.</i></p>
</div>
