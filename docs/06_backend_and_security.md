# Backend & Security (Cloudflare Proxy)

The `purrist-backend/` directory contains the Cloudflare Worker code that acts as our serverless, edge-network proxy.

## The Groq Integration Threat Model
Purrist relies on the **Groq API** to provide sub-millisecond inference for the LLaMA 3 70B model. This speed is non-negotiable; if the AI cat takes 5 seconds to respond, the illusion of life is broken.

However, to use Groq, an API key is required.
If we place the `GROQ_API_KEY` directly inside the Flutter app's codebase (e.g., in a `.env` file that gets bundled into the APK):
1. A malicious actor can easily decompile the APK using tools like `apktool`.
2. They can extract the API key.
3. They can use our key to run their own massive LLM workloads, leading to rapid resource exhaustion, API rate limits, and massive financial bills.

## The Edge Proxy Solution
To mitigate this, the Flutter app **never** sees the Groq API key.

1. We wrote a **Cloudflare Worker** in TypeScript (`purrist-backend/src/`).
2. We securely stored the `GROQ_API_KEY` inside Cloudflare's encrypted environment variables.
3. The Worker exposes a public endpoint.

### The Request Flow
1. **Client (Flutter):** The user types a message. The Flutter app constructs a JSON payload containing the system prompt (with health data injected) and the user's message. It POSTs this payload to the Cloudflare Worker URL.
2. **Worker (Cloudflare):** Receives the payload. It intercepts the HTTP request, reads its own encrypted environment variables, and injects `Authorization: Bearer <GROQ_API_KEY>` into the headers.
3. **Forwarding:** The Worker forwards the modified request to `https://api.groq.com/openai/v1/chat/completions`.
4. **Streaming Response:** As Groq streams the LLM response tokens back to the Worker, the Worker instantly pipes that stream back down to the Flutter client.

### Why Cloudflare Workers?
We chose Cloudflare Workers instead of a traditional Node.js/Express server or AWS Lambda because:
- **Edge Computing:** Workers run on Cloudflare's edge network, meaning the code executes in a data center physically closest to the user, minimizing latency.
- **Cold Starts:** Workers have virtually zero cold start times, unlike AWS Lambda. This ensures the first message to the cat is just as fast as the tenth message.
- **Cost:** Generous free tiers during the hackathon phase.
