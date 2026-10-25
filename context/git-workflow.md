# Git Hygiene & Branch Protection

## Branch Strategy

All development follows isolated feature branches. Main branch (`main`) is protected.

### Branch Naming Convention

| Branch Type | Naming Pattern | Example |
|-------------|---------------|---------|
| **Feature** | `feature/\` + ticket\` + \`-\` + description` | `feature/auth-riverpod`, `feature/offline-sync` |
| **Bug Fix** | `fix/\` + ticket\` + \`-\` + description` | `fix/checkout-crash`, `fix/search-empty-state` |
| **Hotfix** | `hotfix/\` + version\` + \`-\` + description` | `hotfix/1.0.1-payment-timeout` |
| **Release** | `release/\` + version` | `release/1.2.0` |
| **Merge Request / PR** | merge from feature → main | — |

### Branch Protection Rules (Main Branch)

| Rule | Configuration |
|------|--------------|
| **No direct pushes** to `main` | Requires PR/merge request |
| **Minimum reviewers** | 2 approvals from approved coders |
| **Status checks** must pass | CI: lint, test, build, analyze |
| **Branch must be up-to-date** | Rebase or merge `main` before merging |
| **No squash-only** (required merge commit) | Preserves history, feature branch visibility |
| **Required templates** | PR title + description + checklist |

### Pull Request Template

```markdown
## PR Title Convention
[type]/[scope]: description

Types: feat, fix, docs, style, refactor, test, chore
Scope: auth, search, listings, bookings, notifications, ai, infrastructure

## Description
- What does this PR change?
- Which user story/epic does it satisfy?
- Any breaking changes?

## Checklist (MANDATORY - check all that apply)
- [ ] Code follows `coding-standards.md` conventions
- [ ] Riverpod `@riverpod` generator annotations used (not manual Provider)
- [ ] Sealed class FSM states handled exhaustively in UI (`when(...)`)
- [ ] Offline-first: all network operations go through Repository pattern
- [ ] Optimistic UI: local modifications process at 0ms latency
- [ ] No API keys in client-side code or commit messages
- [ ] Tests written for domain use cases (`test/` folder)
- [ ] `flutter pub run build_runner build` ran successfully
- [ ] `flutter analyze` returns no errors
- [ ] Screenshots added for UI changes
- [ ] Updated `development-phases.md` if phase boundary crossed

## Linked Stories
- Epic: \[Epic name\]
- Story: \[Story title or number\]

## Screenshots (if UI change)
<!-- Add before/after screenshots for review -->
```

### Git Commit Message Convention (Conventional Commits)

```
<type>(<scope>): <subject>

<body>

<footer>
```

| Type | Description |
|------|-------------|
| `feat` | New feature (e.g., `feat/listings: add calendar toggle`) |
| `fix` | Bug fix (e.g., `fix/search: handle empty results state`) |
| `docs` | Documentation changes |
| `style` | Formatting, missing semicolons, missing lint (no code change) |
| `refactor` | Code restructure, no behavior change |
| `test` | Adding missing tests |
| `chore` | Build steps, dependency updates, config changes |

### Example Commit Flow

```
# 1. Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/offline-sync

# 2. Develop commits (atomic, single-purpose)
git add .
git commit -m "feat/offline-sync: add Hive local cache layer"
git commit -m "feat/offline-sync: implement pull-to-refresh flow"
git commit -m "feat/offline-sync: add sync queue with conflict resolution"

# 3. Push branch and open PR
git push -u origin feature/offline-sync

# 4. Wait for 2 reviewer approvals + CI checks
# 5. After approval: squash and merge to main
git checkout main
git pull origin main
git merge --squash feature/offline-sync
git commit -m "feat: complete offline-first sync implementation"

# 6. Delete feature branch
git branch -d feature/offline-sync
git push origin --delete feature/offline-sync
```

### Conflict Resolution Workflow

```
1. Developer creates feature branch from latest main
2. Developer works in isolation with frequent rebases
3. If merge conflict occurs:
   a. git status → identify conflicted files
   b. git mergetool → resolve visual merge
   c. flutter pub get && flutter analyze → verify no breakage
   d. git add . && git commit --amend --no-edit
4. Push resolved branch, PR reviewers verify resolution
5. Main branch protected - only merges with resolved conflicts
```

### CI/CD Gates (Recommended)

| Gate | Command |
|------|---------|
| **Lint** | `flutter analyze` |
| **Formatter** | `dart format --set-exit-if-changed` |
| **Tests** | `flutter test` with coverage ≥80% |
| **Build Runner** | `flutter pub run build_runner build --delete-conflicting-outputs` |
| **iOS Build** | `flutter build ios --debug` (verify no compile errors) |
| **Android Build** | `flutter build android --debug` (verify no compile errors) |