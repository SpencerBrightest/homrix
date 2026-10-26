# AI Integration Bridge

## Status

Proposed security and contract guidance. No AI feature, backend endpoint, or
provider integration currently exists. Final request/response schemas must be
versioned with the backend before client implementation.

## Security Boundary

All AI provider calls and provider credentials stay server-side. The Flutter
client calls an authenticated Homrix backend endpoint only; never bundle a
provider API key, call a provider directly, or treat model output as trusted
instructions. The backend enforces authorization, rate limits, input/output
limits, moderation policy, and audit/privacy requirements.

Do not send unnecessary personal data, authentication tokens, payment details,
or private host/guest messages to an AI service. Define retention and consent
behavior before launch. Treat generated text and structured output as untrusted
and validate it before rendering, storing, or acting on it.

## Candidate Contracts

These are illustrative shapes only; the backend must finalize field names,
validation, error responses, and versioning.

Natural-language listing search request:

```json
{
  "query": "A quiet place near the waterfront for two guests",
  "filters": {
    "guestCount": 2,
    "checkIn": "2026-11-01",
    "checkOut": "2026-11-04"
  }
}
```

Possible response:

```json
{
  "requestId": "opaque-request-id",
  "listingIds": ["opaque-listing-id"],
  "clarification": null
}
```

Host copy-generation request:

```json
{
  "listingId": "opaque-listing-id",
  "field": "summary",
  "tone": "welcoming",
  "sourceText": "A short description supplied by the host"
}
```

Possible response:

```json
{
  "requestId": "opaque-request-id",
  "suggestion": "Generated draft text for host review"
}
```

Do not assume these example fields or the example dates are production
requirements. Prefer returning listing IDs or constrained suggestions instead
of allowing model output to bypass normal search, authorization, or booking
validation.

## Client Integration

Call the backend through a repository/data-source boundary. Expose loading,
success, empty/clarification, and recoverable-error states through generated
Riverpod providers once Riverpod is installed. The user should review and
explicitly accept generated copy; AI output must not publish listings or create
bookings automatically.

## Acceptance Checks

- No provider key or direct provider endpoint exists in the client bundle.
- Requests are authenticated, validated, bounded, and covered by rate limits on
  the backend.
- Client parsing handles malformed responses, refusal/error cases, and unknown
  contract versions.
- Tests verify that generated content is a suggestion and requires explicit
  user action before persistence.
