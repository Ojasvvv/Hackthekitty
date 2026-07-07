# System Architecture

Purrist is built for extreme responsiveness, secure offline-first persistence, and robust identity management. 

## High-Level Tech Stack
- **Frontend Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Local Persistence:** SharedPreferences (Offline-first architecture)
- **Authentication:** Firebase Authentication
- **Edge Proxy:** Cloudflare Workers (TypeScript)
- **AI Inference Engine:** Groq API (running LLaMA 3 70B)
- **Hardware Integration:** Android `usage_stats` and `health` APIs.

---

## 1. Frontend: Flutter & Riverpod
### Why Flutter?
Flutter was chosen because it allows us to paint stunning, custom Neobrutalist UI components at 60FPS on a completely custom canvas. Material 3 and Cupertino were highly limiting for the harsh borders and bold shadows required by the design system. 

### Why Riverpod?
Riverpod was chosen over Provider or BLoC for its declarative, compile-safe nature.
Crucially, Riverpod excels at **provider invalidation**. When a user logs out, Riverpod can instantly tear down the current dependency tree and rebuild it, ensuring state does not leak between sessions.

---

## 2. Authentication & Multi-Tenant State Isolation
We use **Firebase Auth** for Email/Password and Google OAuth sign-in.

### The SharedPreferences Problem
To ensure rapid startup times and true offline capability (so the app works when on airplane mode), everything from the LLaMA 3 chat history to the user's task list (Scratchpad) is saved locally via `SharedPreferences`.

However, multiple users might log into the same device. If we just saved tasks to a key called `tasks_list`, User B would see User A's data.

### The Solution: Dynamic UID Prepending
We implemented strict multi-tenant isolation on the client.
When saving or loading data, the persistence layer dynamically prepends the current Firebase `uid` to every single key.
`"USER_ID_1234_chat_history"` vs `"USER_ID_5678_chat_history"`

When Riverpod detects an authentication state change (via `FirebaseAuth.instance.authStateChanges()`), it forces all local data providers to rebuild, swapping out the underlying `uid` prefix. This provides perfect local data separation without relying on a slow, online-only backend database like Firestore.

---

## 3. Serverless Edge Architecture (Cloudflare & Groq)
The intelligence of the app relies on the **Groq API** running the massive **LLaMA 3 70B** model, providing sub-millisecond inference speeds.

### The Security Threat
Hardcoding the Groq API key into the Flutter app is a massive security vulnerability. Anyone can decompile an APK and scrape the key, leading to rapid resource exhaustion and financial loss.

### The Edge Proxy Solution
We deployed a serverless **Cloudflare Worker** as an edge proxy in the `purrist-backend/` directory.

**The Request Flow:**
1. **Flutter App:** Builds the system prompt (injecting health metrics) and sends an HTTP POST request to the public Cloudflare Worker URL. No API keys are sent from the client.
2. **Cloudflare Worker:** Receives the request at the edge (closest to the user). It securely reads the hidden Groq API key from its own encrypted environment variables, injects it into the `Authorization` header, and forwards the payload to Groq.
3. **Groq API:** Processes the LLM inference and streams the response back to the Worker.
4. **Cloudflare Worker:** Streams the LLaMA 3 response back to the Flutter app.

This architecture ensures 100% protection against API key scraping while maintaining the ultra-low latency required for real-time chat.
