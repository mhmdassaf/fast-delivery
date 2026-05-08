---
name: feature-doc
description: Auto-create/update AI-readable feature documentation in docs/ folder
license: MIT
compatibility: opencode
metadata:
  audience: git-agent
  workflow: flutter
---

## What I do

- Infer feature names from modified file paths (pattern: `packages/<feature>/` or `apps/*/lib/features/<feature>/`)
- Create new feature documentation in `docs/<feature>_feature.md` using project template (based on `docs/auth_feature.md`)
- Update existing feature docs with code change details:
  - New/modified screens → Update Navigation section
  - New/modified Riverpod providers → Update State Management section
  - New/modified Freezed models → Update Data Models section
  - New Firebase operations → Update Firebase Integration section
  - New UI widgets → Update UI Components section
- Write doc updates directly to `docs/<feature>_feature.md`

## When to use me

Triggered automatically by Git-agent in Phase 2.5 (after feature file detection, before staging). Can also be triggered manually via `/feature-doc`.

## Workflow

1. Receive list of modified files from Git-agent (output of Phase 2)
2. Infer feature name(s) from file paths:
   - Match `packages/<feature>/` → feature = <feature>
   - Match `apps/<app>/lib/features/<feature>/` → feature = <feature>
   - Group files by detected feature
3. For each detected feature:
   a. Check if `docs/<feature>_feature.md` exists
   b. If not: Create new doc using `docs/auth_feature.md` as template, replace auth-specific content with new feature's details
   c. If exists: Analyze modified files for the feature and update relevant sections (Navigation, State Management, etc.)
4. Write updated content to `docs/<feature>_feature.md`
5. Return list of updated doc files to Git-agent for inclusion in staging
