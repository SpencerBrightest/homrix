# Development Phases & Roadmap

## 5-Phase Delivery Plan (from User Stories)

### Phase 1: Foundation (Weeks 1-3)
**Goal**: Establish architecture baseline, authentication, and local cache.

| Week | Deliverables |
|------|-------------|
| 1 | ⭐ Project init, Git hygiene, branch protection setup<br>Riverpod `build_runner` configured<br>Hive/Isar local cache baseline<br>Auth FSM sealed class + Riverpod providers |
| 2 | ⭐ Authentication flow (email/password + biometric)<br>Persistent session management<br>Role-based onboarding (guest/host/admin)<br>Riverpod FSM: AuthState complete |
| 3 | ⭐ Repository pattern baseline (Local + Remote datasources)<br>Unit tests for domain layer (≥80% coverage)<br>CI: lint, analyze, test pass on `main` |

**Exit Criteria**: Auth works end-to-end; `flutter analyze` clean; `flutter test` passes; main branch protected.

---

### Phase 2: Core Marketplace (Weeks 4-6)
**Goal**: Search & Discovery + Listing Management (primary guest & host flows).

| Week | Deliverables |
|------|-------------|
| 4 | ⭐ Search screen with Riverpod FSM (`SearchState` sealed class)<br>Pull-to-refresh via `ref.invalidate()`<br>Filter chips with optimistic UI updates |
| 5 | ⭐ Host listing creation form (photos, description, pricing)<br>Calendar management UI (min stay, cleaning fees)<br>Real-time payout state monitoring |
| 6 | ⭐ Infinite scroll/pagination on search results<br>Infinite scroll paginated Riverpod state<br>Offline cache: last search results persisted |

**Exit Criteria**: Search → listings flow works offline; pull-to-refresh fetches fresh data; calendar UX functional; unit test coverage ≥80% for Phase 2.

---

### Phase 3: Transaction & Real-Time (Weeks 7-9)
**Goal**: Booking flow + real-time streams + notifications.

| Week | Deliverables |
|------|-------------|
| 7 | ⭐ Booking initiation flow (guest selects dates → request)<br>Booking FSM (`BookingIdle → BookingSubmitting → BookingSuccess/Failure`)<br>Optimistic UI: heart fills immediately, sync queues background |
| 8 | ⭐ Real-time StreamProviders for booking tracking<br>Firestore snapshots + distinct() for dedup<br>WebSocket fallback if Firestore latency too high |
| 9 | ⭐ FCM notification engine setup<br>Topic subscriptions (/topics/guests, /topics/hosts)<br>Background handler for booking confirmations/cancellations |

**Exit Criteria**: Booking request processes locally at 0ms; host receives notification instantly; streams reconnect after network loss; FCM test passed on both Android/iOS simulators.

---

### Phase 4: Advanced & Security (Weeks 10-12)
**Goal**: Secured AI layer, conflict resolution, edge cases.

| Week | Deliverables |
|------|-------------|
| 10 | ⭐ AI gateway integration (`/api/ai/concierge`, `/api/ai/generate-listing`)<br>PII scrubbing at gateway level<br>Rate limiting per user<br>API key rotation via backend (no app update) |
| 11 | ⭐ Conflict resolution: offline edits vs server updates<br>Last-write-wins + field-level merge<br>User prompt for same-field conflicts<br>Sync queue persistence across app restarts |
| 12 | ⭐ Admin dashboard (validation policies, conflict logs, service fees)<br>Admin FSM states implementation<br>Audit logging for all AI/booking operations |

**Exit Criteria**: AI calls go through gateway only (no keys in client); conflict resolution tested; admin features functional; full test suite passes.

---

### Phase 5: Polish & Stability (Weeks 13-14)
**Goal**: Resilience, performance, release preparation.

| Week | Deliverables |
|------|-------------|
| 13 | ⭐ Offline resilience: app works in airplane mode<br>Queue persistence across restarts<br>Graceful degradation UI when offline |
| 14 | ⭐ Performance optimization (build runner, tree shake)<br>Final `flutter analyze` zero warnings<br>Release signing (Android Keystore + iOS Distribution)<br>Final PR to main + main branch protection confirmed |

**Exit Criteria**: Release candidate ready; all 5 phases complete; main branch green; documentation complete.

---

## Phase Dependencies Graph

```
Phase 1 (Foundation)
       │
       ▼
Phase 2 (Core Marketplace) ← Auth + Repository required here
       │
       ▼
Phase 3 (Transaction & Real-Time) ← Booking + Streams + FCM
       │
       ▼
Phase 4 (Advanced & Security) ← AI gateway + Conflict resolution
       │
       ▼
Phase 5 (Polish & Stability) ← Release candidate
```

---

## Phase Gate Checklist

Before progressing to next phase, ALL must pass:

- [ ] `flutter analyze` returns zero warnings/errors
- [ ] `flutter test` passes with ≥80% coverage for current phase
- [ ] `flutter pub run build_runner build` completes without errors
- [ ] Feature branch merged to main via squash merge
- [ ] Main branch CI passes (lint + test + build)
- [ ] No API keys or secrets in committed code or git history
- [ ] Documentation updated (`context/*.md` files in sync)
- [ ] Screenshots updated for merged features
- [ ] Phase-specific exit criteria met (see above)