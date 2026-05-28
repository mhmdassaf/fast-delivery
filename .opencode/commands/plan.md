---
description: Scan all existing docs, summarize existing features, then produce a well-informed implementation plan for a new feature
---

## Step 1 — Scan existing documentation
1. Use glob to find all `docs/*.md` files
2. Read every markdown file found in `docs/`
3. For each file, extract and note:
   - Feature name and purpose
   - Architecture pattern used (shared package vs app-local)
   - Key data models / Firestore collections
   - Routes / navigation structure
   - Dependencies on other features
   - Current implementation status

## Step 2 — Summarize what exists
Present a concise summary of all existing features, their scope, and their relationships. Highlight:
- Which features already exist (to avoid duplication)
- Shared patterns across features
- Architectural conventions already established
- Any obvious gaps or inconsistencies

## Step 3 — Ask user for the new feature
Ask the user: **"Which feature would you like to plan?"** and wait for their input.

## Step 4 — Produce the implementation plan
After the user specifies the feature, produce a detailed plan covering:
1. **Feature scope** — What it includes (and explicitly what it excludes)
2. **Architecture** — Shared package or app-local? Which layer?
3. **Files to create/modify** — Full file paths following Clean Architecture (data/domain/presentation)
4. **Data models** — Firestore schema if applicable (collections, fields, types)
5. **State management** — Riverpod providers and notifier state
6. **Navigation** — Routes and screen flow
7. **Dependencies** — On existing features, packages, or external services
8. **Implementation order** — Step-by-step build sequence
9. **Edge cases & error handling** — Failure states to handle
10. **Doc update** — Which `docs/*.md` file(s) to create/update

## Step 5 — Confirm
Present the full plan and ask the user to confirm before any code is written.
