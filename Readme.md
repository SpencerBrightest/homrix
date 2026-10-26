# 📌 Cross-Platform Airbnb Architecture Clone (High-Fidelity Learning Vehicle)

## Supabase email authentication setup

1. Copy `.env.example` to `.env` in the project root.
2. Set `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` from the Supabase
   project's API settings. Alternatively, the legacy anon key can be set as
   `SUPABASE_ANON_KEY`.
3. Run `flutter pub get`, then launch the app.

Riverpod's keep-alive auth controller restores the Supabase session before
resolving the startup route and subscribes to Supabase auth events so sign-in,
sign-out, and token refreshes update the app shell. It supports email/password
sign-in, sign-up, and sign-out. When email confirmation is enabled in Supabase,
sign-up displays a confirmation prompt and keeps the user outside the protected
home route until they sign in.

Apply the SQL migration in `supabase/migrations/` to the Supabase project.
It assigns the trusted `app_metadata.role` to new accounts (`user` by default)
and preserves a trusted `admin` role. The app reads this value into the user
profile. Signup also sends `user_metadata.role=user`, but that value is
client-editable and is informational only; use `app_metadata` and Row Level
Security policies for authorization.

`.env` is excluded by `.gitignore`; do not commit it. Values shipped in a
Flutter app are extractable, so a Supabase anon/publishable key is public
configuration, not a secret. Never put a Supabase `service_role` key, database
password, or other privileged secret in this file or in the client app. Enforce
data access with Supabase Row Level Security policies and keep privileged
operations on a trusted server.

## ⚠️ ABSOLUTE AGENT CONSTRAINT: SYSTEM BOUNDARY MANDATE

- **Zero Vibe Coding:** This project is strictly an educational vehicle designed to master deterministic architectures, edge cases, and structural data mutations.
- **No Shortcuts:** Do not use shallow abstractions, generic boilerplate bypasses, or quick-fix hacks to "make it work."
- **Educational Explanations:** Every code module generated must include clear explanations of the underlying structural engineering decisions ("why" and "how") to build permanent architectural literacy.
- **Enterprise Standards Only:** Treat this repository as if it were a high-traffic, commercial cross-platform mobile production system.

---

## 🏗️ 1. Technical Guardrails & Stack Blueprint

The target is **Android and iOS** from one Flutter codebase. The repository
already uses Riverpod and Supabase email authentication; the marketplace
backend and remaining integrations are still evolving.

- **Current stack:** Flutter, Dart, Riverpod, GoRouter, and Supabase Flutter
  (see `pubspec.yaml`).
- **Planned UI and state:** Flutter and Dart with Riverpod Generator
  (`@riverpod`) for dependency injection, app state, and reactive data
  coordination. Do not add Redux, Zustand, or TanStack Query without an
  explicit architecture decision.
- **Planned persistence:** A durable local database is the source of truth
  for cached data shown by the UI. The database engine is not selected yet;
  Riverpod provider state is not a replacement for persistent storage.
- **Planned data access:** Clean Architecture with the Repository Pattern.
  `[UI] -> [Riverpod] -> [Repository / Local Cache]`; repositories
  synchronize with the remote API and write accepted data to the local cache.

## Stack Summary

| Area              | Current                | Target                                                             |
| ----------------- | ---------------------- | ------------------------------------------------------------------ |
| Client            | Flutter + Dart         | Flutter for Android and iOS                                        |
| State             | Riverpod Generator     | Riverpod Generator (`@riverpod`)                                   |
| Persistence       | Not configured         | Offline-first local database (decision pending)                    |
| Data access       | Not configured         | Repository Pattern; UI observes local data                         |
| Authentication    | Supabase email/password| Supabase Auth; RLS-backed authorization                            |
| Backend, push, AI | Partial                | Secure server APIs; FCM and server-side AI are future integrations |

## Visual Direction

Use an **Airbnb-inspired** palette: bright coral-red as the action accent,
balanced by white surfaces, near-black text, and restrained neutral grays. This
is a design reference, not an affiliation with or use of Airbnb branding.

| Role                           | Color      | Hex       |
| ------------------------------ | ---------- | --------- |
| Primary accent and key actions | Coral red  | `#FF385C` |
| Main text and icons            | Near black | `#222222` |
| Secondary text                 | Mid gray   | `#717171` |
| Page background                | Soft gray  | `#F7F7F7` |
| Surfaces                       | White      | `#FFFFFF` |
| Dividers and subtle borders    | Light gray | `#DDDDDD` |

Use the coral accent selectively for primary actions and active states. Keep
body text and controls high-contrast and verify text contrast when implementing
the app theme.

## Website and App UI Rules

- Define palette values once as semantic theme tokens (for example,
  `colorPrimary`, `colorText`, `colorTextMuted`, `colorSurface`,
  `colorBackground`, and `colorDivider`). Use the same tokens across web and
  mobile implementations rather than scattering raw hex values.
- Reserve coral for primary calls to action, selected navigation, and important
  interactive states. Do not use it as a large page background or for long body
  text. Use neutral backgrounds and white content surfaces to keep listings and
  photography prominent.
- Use near-black for primary text, mid-gray for secondary text, and light gray
  for borders. Keep text and icons distinguishable from their backgrounds.
- Check WCAG AA contrast for text and controls. The coral accent is not
  automatically suitable for small text or white text; choose a sufficiently
  dark treatment when a contrast check fails. Never communicate status by color
  alone: pair it with a label, icon, or other clear cue.
- Keep success, warning, and error colors semantically distinct from the brand
  accent. Add those tokens only when the corresponding states are implemented,
  and check their contrast in each theme.
- Use a clear sans-serif type system with consistent heading, body, and caption
  styles. Use spacing and alignment consistently, and keep cards and controls
  restrained so property imagery and information remain the focus.
- Design responsively for narrow phones through wide desktop screens. Prevent
  text clipping and overlapping controls, and provide visible keyboard focus
  and accessible names for interactive elements on the web.
- Keep the visual direction light-first unless a dark theme is specifically
  designed and tested. Do not copy Airbnb logos, proprietary fonts, or branded
  assets; this palette is inspiration, not a claim of affiliation.

---

## 👥 2. Multi-Sided Marketplace System Actors

Your codebase must natively isolate data boundaries, context visibility, and system interactions across three core actors:
