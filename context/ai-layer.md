# Secured AI Layer

## Backend Gateway Pattern

All AI orchestrations (Smart Concierge & Host Copy Generators) are isolated behind a **dedicated backend gateway**. API keys **must not reside client-side**.

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    MOBILE APP (Flutter/Dart)                   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  /api/ai/concierge  (POST)                               │ │
│  │  /api/ai/generate-listing (POST)                        │ │
│  │  /api/ai/translate (POST)                               │ │
│  └──────────────────────────────────────────────────────────┘ │
│           ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  │
│           │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │
│           │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │
│    ┌─────────────┴─────────────┴─────────────┴─────────────┴┐ │
│    │              SECURED JSON ENDPOINT LAYER                 │ │
│    │  - HTTPS only, never HTTP                                │ │
│    │  - Request signing (JWT or mutual TLS)                   │ │
│    │  - Rate limiting per user/IP                             │ │
│    │  - Input validation & PII scrubbing                      │ │
│    │  - Output sanitization                                   │ │
│    └──────────────────────────────────────────────────────────┘ │
│                   ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲ │
│                   │  │  │  │  │  │  │  │  │  │  │  │  │  │ │
│  ┌──────────────┴───────────────────────┴─────────────────┴────┐│
│  │              BACKEND AI GATEWAY (Node/Go/Python)           ││
│  │                                                              ││
│  │  ┌─────────────────────┐  ┌────────────────────────────────┐ ││
│  │  │  OpenAI / Anthropic │  │  Custom LLM Prompt Templates     │ ││
│  │  │  API Integration    │  │  - Listing description generator │ ││
│  │  │  - Key: OPENAI_KEY │  │  - Concierge response formatter  │ ││
│  │  │  - Env var only     │  │  - Copy style matcher (host voice)│ ││
│  │  └─────────────────────┘  └────────────────────────────────┘ ││
│  │           ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ││
│  │           │  │  │  │  │  │  │  │  │  │  │  │  │  │  ││
│  │  ┌────────┴────────┴───────┴───────┴───────┴───────┴─────┤││
│  │  │  SECURITY & COMPLIANCE LAYER                              │││
│  │  │  - API keys in ENV vars only (never in code)            │││
│  │  │  - Rotate keys weekly without app update                │││
│  │  │  - Rate limiting: 100 req/min/user                      │││
│  │  │  - PII detection: scrub emails, phone numbers          │││
│  │  │  - Response filtering: no raw API data to client        │││
│  │  │  - Audit log: every AI request/response                │││
│  │  └──────────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────┘┘
└─────────────────────────────────────────────────────────────────┘
```

### Client-Side Implementation

```dart
// ❌ NEVER: API keys in .env, source code, or client-side storage
// ❌ NEVER: direct OpenAI/Anthropic SDK calls from Flutter

// ✅ CORRECT: Gateway-mediated AI calls

// 1. Concierge - Guest property recommendations
Future<ConciergeResponse> getConciergeRecommendations({
  required String userQuery,
  required List<ListingPreferences> preferences,
  required BuildContext context,
}) async {
  final response = await http.post(
    Uri.parse('/api/ai/concierge'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${ref.read(userTokenProvider)}',
    },
    body: jsonEncode({
      'query': userQuery,
      'preferences': preferences.toJson(),
      'userContext': {
        'location': ref.read(locationProvider),
        'budgetRange': ref.read(budgetProvider),
        'guestCount': ref.read(guestCountProvider),
      },
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('AI service unavailable');
  }

  return ConciergeResponse.fromJson(jsonDecode(response.body));
}

// 2. Host Copy Generator - AI listing description
Future<ListingDescription> generateListingDescription({
  required ListingFeatures features,
  required String hostVoiceStyle,
  required String propertyType,
}) async {
  final response = await http.post(
    Uri.parse('/api/ai/generate-listing'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'features': features.toJson(),
      'hostVoiceStyle': hostVoiceStyle,
      'propertyType': propertyType,
    }),
  );

  return ListingDescription.fromJson(jsonDecode(response.body));
}
```

### Gateway Security Implementation (Node/Go Example)

```go
// go/ai-gateway/main.go
package main

import (
    "context"
    "fmt"
    "net/http"
    "os"
    "time"
    
    "github.com/openai/go-openai"
    "github.com/golang-jwt/jwt/v5"
)

// Rate limiter (token bucket)
type rateLimiter struct {
    tokens  int
    replenishRate time.Duration
    lastReplenish time.Time
    mu          sync.Mutex
}

func (rl *rateLimiter) Allow() bool {
    rl.mu.Lock()
    defer rl.mu.Unlock()
    
    now := time.Now()
    if now.Sub(rl.lastReplenish) > rl.replenishRate {
        rl.tokens = 100 // max tokens
        rl.lastReplenish = now
    }
    
    if rl.tokens > 0 {
        rl.tokens--
        return true
    }
    return false
}

// PII scrubbing
func scrubPII(input string) string {
    // Remove email addresses
    input = regexEmail.ReplaceAllString(input, "[EMAIL]")
    // Remove phone numbers
    input = regexPhone.ReplaceAllString(input, "[PHONE]")
    // Remove credit card numbers (basic)
    input = regexCC.ReplaceAllString(input, "[CC]")
    return input
}

// AI concierge endpoint
func conciergeHandler(w http.ResponseWriter, r *http.Request) {
    // 1. Auth check
    authHeader := r.Header.Get("Authorization")
    if authHeader == "" {
        http.Error(w, "unauthorized", http.StatusUnauthorized)
        return
    }
    
    // 2. Rate limiting
    if !rl.Allow() {
        http.Error(w, "rate limit exceeded", http.StatusTooManyRequests)
        return
    }
    
    // 3. Parse request
    var req struct {
        Query string `json:"query"`
        // ... other fields
    }
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "invalid request", http.StatusBadRequest)
        return
    }
    
    // 4. PII scrubbing on input
    sanitizedQuery := scrubPII(req.Query)
    
    // 5. OpenAI call - key from ENV ONLY
    client := openai.NewClient(os.Getenv("OPENAI_API_KEY"))
    
    resp, err := client.CreateChatCompletion(
        context.Background(),
        openai.ChatCompletionParams{
            Model:    "gpt-4o-mini",
            Messages: []openai.ChatCompletionMessage{
                {"system", "You are a Smart Concierge for Airbnb. Provide helpful property recommendations."},
                {"user",  sanitizedQuery},
            },
            Temperature: 0.7,
        },
    )
    
    if err != nil {
        log.Error.Printf("OpenAI error: %v", err)
        http.Error(w, "ai service error", http.StatusInternalServerError)
        return
    }
    
    // 6. Response filtering - strip raw API data
    aiResponse := resp.Choices[0].Message.Content
    
    // 7. Audit log
    go func() {
        awaitLogAudit(r, "concierge", sanitizedQuery, aiResponse)
    }()
    
    // 8. Send cleaned response
    json.NewEncoder(w).Encode(map[string]string{
        "response": aiResponse,
        "requestId": uuidv4(),
    })
}
```

### Key Rules

| Rule | Rationale |
|------|-----------|
| **API keys NEVER** in Flutter assets, .env, or Dart code | Prevent key theft, unauthorized usage, rotation impossible client-side |
| **ALL** AI calls go through `/api/ai/*` endpoints | Single choke point for rate limiting, logging, PII scrubbing |
| **HTTPS ONLY** - never HTTP for AI endpoints | MITM protection, credential forwarding safety |
| **Input validation + PII scrubbing** at gateway | Compliance (GDPR/CCPA), prevent leaking user data to LLMs |
| **Response filtering** - strip raw API metadata | UI consistency, prevent accidental key/token exposure in client |
| **Rotate keys weekly** via backend - no app update needed | Operational agility, minimize blast radius if key compromised |
| **Audit log** every AI request/response | Security forensics, cost tracking, abuse detection |
| **Rate limiting per user/IP** | Prevent cost overruns, fair usage across all users |
| **Model version pinning** (gpt-4o-mini@2024-05-13) | Predictable behavior, can rollback without client change |