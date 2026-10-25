# Agents Guide - How to Use This Context

## Purpose

This `context/` folder contains markdown files that document the **Airbnb Marketplace Clone** architecture, patterns, and standards for agents to reference during development. Think of these as the "design documents" that would normally live in a software design spec.

## How Agents Should Use These Files

### 1. **Read Before Starting Any Task**
- When assigned a new feature/story, FIRST read the relevant context files
- Example: "Add pull-to-refresh → read `context/offline-sync.md` first"
- Example: "Add AI concierge → read `context/ai-layer.md` first"

### 2. **File Reference Mapping**

| If working on... | Read these files first |
|------------------|----------------------|
| Authentication | `auth.md`, `state-management.md`, `project-structure.md` |
| Search & Filters | `architecture.md`, `state-management.md`, `offline-sync.md` |
| Listing Management | `architecture.md`, `state-management.md`, `project-structure.md` |
| Booking Flow | `offline-sync.md`, `real-time-streams.md`, `state-management.md` |
| FCM Notifications | `notifications.md`, `real-time-streams.md` |
| AI Concierge/Copy | `ai-layer.md`, `coding-standards.md` |
| Admin Dashboard | `architecture.md`, `development-phases.md`, `coding-standards.md` |
| General Riverpod patterns | `state-management.md` |
| Git workflow / PRs | `git-workflow.md` |

### 3. **Task Delegation Pattern**

When assigning work to agents, include:

```
TASK: Add pull-to-refresh to search results screen

READ FIRST:
  - context/offline-sync.md (pull-to-refresh flow, repository pattern)
  - context/state-management.md (Riverpod FSM patterns)
  - context/project-structure.md (feature folder layout)

IMPLEMENTATION REQUIREMENTS:
  ✅ Use ref.invalidate(searchProvider) NOT setState()
  ✅ SearchState sealed class FSM with .when() handling
  ✅ Repository pattern: UI reads from local cache only
  ✅ Optimistic UI: local mods process at 0ms, sync queues background
  ✅ No API keys in Dart code or commit messages

DELIVERABLES:
  - SearchScreen with pull-to-refresh
  - Riverpod provider with FSM sealed class
  - Repository impl (local + remote)
  - Unit test for refresh flow
  - Update context/ if patterns evolve
```

### 4. **Quality Gates - Check Before Marking Complete**

For ANY task, verify these before marking done:

| Check | File to Reference | Command |
|-------|------------------|---------|
| Riverpod @riverpod used | `state-management.md` | `flutter pub run build_runner build` |
| Sealed class FSM `.when()` | `state-management.md` | N/A (code review) |
| Repository pattern used | `offline-sync.md` | `flutter analyze` |
| No API keys in client | `ai-layer.md` | `git grep -i "api.key\|OPENAI\|firebase_key"` |
| Coding standards | `coding-standards.md` | `dart format --set-exit-if-changed` |
| Tests exist | `development-phases.md` | `flutter test` |
| Git commit format | `git-workflow.md` | `git log --oneline -5` |

### 5. **When to Create NEW Context Files**

Create a new `context/\[name].md` file when:

- ✅ Pattern emerges that isn't covered by existing docs
- ✅ New team member asks "how do we handle X?"
- ✅ Architecture decision needs documenting for future reference
- ✅ Onboarding new agent - add to `agents-guide.md`

**Do NOT** create new files for:
- ❌ One-off code snippets (keep in implementation)
- ❌ Temporary notes (use comments or TODO)
- ❌ Random thoughts (stay in plan mode discussions)

### 6. **Context File Maintenance**

- **On PR merge**: Author updates relevant `.md` files if patterns changed
- **On phase gate**: Review `.md` files for accuracy before progressing
- **Quarterly review**: Assess if context files still match codebase reality
- **New feature**: Add patterns to existing file OR create new if domain-unique

### 7. escalation Path

If context files don't cover your scenario:

1. Check `context/agents-guide.md` for patterns
2. Search existing files for related topics
3. Ask in team channel (reference the relevant `.md` file)
4. If truly novel, create new `context/\[name].md` and update this guide

### 8. Quick Reference - Most Frequently Used

| File | Usage Frequency | Key Content |
|------|----------------|-------------|
| `state-management.md` | ★★★★★ | Riverpod FSM, sealed classes, `.when()` patterns |
| `offline-sync.md` | ★★★★★ | Repository pattern, pull-to-refresh, optimistic UI |
| `architecture.md` | ★★★★☆ | 3 actors, data flow diagram, repository layer |
| `coding-standards.md` | ★★★★☆ | Forbidden patterns, Riverpod annotations, formatting |
| `git-workflow.md` | ★★★★☆ | Branch protection, PR template, commit conventions |
| `development-phases.md` | ★★★★☆ | 5-phase plan, dependencies, exit criteria |
| `notifications.md` | ★★★☆☆ | FCM, local vs remote, topic subscriptions |
| `ai-layer.md` | ★★★☆☆ | Backend gateway, PII scrubbing, key rotation |
| `auth.md` | ★★★☆☆ | Auth FSM, biometric, role-based access |
| `project-structure.md` | ★★★☆☆ | Feature-first layout, naming conventions |

---

## Agent Onboarding Checklist

**[ ]** Read `context/agents-guide.md` in full
**[ ]** Read `context/state-management.md` (Riverpod foundations)
**[ ]** Read `context/offline-sync.md` (offline-first patterns)
**[ ]** Set up project: `flutter pub get` + `flutter pub run build_runner build`
**[ ]** Verify `flutter analyze` passes with no errors
**[ ]** Read `context/git-workflow.md` (branch/PR rules)
**[ ]** Read relevant feature context before first task assignment
**[ ]** All code reviews reference the applicable `.md` files

---

**Last Updated**: `development-phases.md` reflects the 5-phase plan from user stories  
**Coverage**: All 11 context files support the Airbnb marketplace clone architecture  
**Contact**: Refer to this guide when uncertain - patterns are documented, not memorized