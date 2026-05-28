# AGENTS.md - Fast Delivery Project

## Project Status

Greenfield Flutter/Firebase multi-app system. No code written yet - this file guides future development.

## Architecture Decisions (Enforced)

- **Pattern**: Clean Architecture (data, domain, presentation layers) + MVVM
- **State Management**: Riverpod
- **Networking**: Dio
- **Models**: Freezed
- **Backend**: Firebase (Auth, Firestore, Cloud Functions, FCM)
- **Roles**: user, rider, seller, admin

## App Structure

Four distinct apps under one repo (future monorepo):

1. **User App** - Customer mobile app
2. **Rider App** - Delivery driver mobile app
3. **Seller App** - Restaurant owner mobile app
4. **Admin Panel** - Web admin dashboard

Shared code goes in separate packages to avoid coupling.

## Agent Configuration

Agents are defined in `.opencode/agents/`:

- `Architect.md` - Design full system structure(use for planning)
- `Flutter-developer.md` - Build Flutter features (no device testing)
- `Flutter-tester.md` - Build, run, and test on Android physical devices (unit, widget, integration tests)
- `Git-agent.md` - Commit and push tested changes cleanly (manual trigger via /git-agent after Flutter-tester, auto-triggers feature-doc)
- `Firebase-developer.md` - Firestore schema & Cloud Functions (Backend)
- `Code-reviewer.md` - Optimize existing code (no longer handles git operations)
- `Designer.md` - UI/UX suggestions only

## Command Configuration

Commands are defined in `.opencode/commands/`:

- `plan` - `/plan` Scan all existing docs in `docs/`, summarize existing features, then produce a well-informed implementation plan for a new feature

## Skill Configuration

Skills are defined in `.opencode/skills/`:

- `feature-doc` - Auto-create/update AI-readable feature documentation in docs/ folder (triggered automatically by Git-agent in Phase 2.5)

## Workflow Order

The recommended workflow for implementing features:

1. **Flutter-developer** - Build features and screens
2. **Code-reviewer** - Optimize existing code (no longer handles git operations)
3. **Flutter-tester** - Build, run, and test on Android physical devices
4. **Git-agent** (manual trigger via `/git-agent`) - Commit and push tested changes cleanly (auto-triggers feature-doc to update docs)

Note: Git-agent replaces all git commit/push functionality previously in Code-reviewer. Git-agent now automatically triggers the `feature-doc` skill in Phase 2.5 to update feature documentation before staging files.

## Key Conventions

- Business logic must stay out of UI
- No hardcoded values
- Use null safety and strong typing
- Code must be modular and reusable
- Write readable and maintainable code

## Feature Documentation (AI-Readable Specs)

All project specifications are in `/docs/` folder.

**Rules for Feature Specs:**

1. Specifications must be updated whenever the feature changes
2. AI agents must read the spec before modifying the feature
3. All new code must follow the patterns documented in the spec
4. Breaking changes require spec update + commit message reference

---

## Implementation Rules (Enforced for Consistency)

**⚠️ Read the relevant spec in `/docs/` before making changes**

### Mandatory Patterns (DO NOT DEVIATE)

1. **Architecture:** Must follow Clean Architecture (data → domain → presentation)
   - Data layer: `features/{feature}/data/`
   - Domain layer: `features/{feature}/domain/` (providers/notifiers)
   - Presentation layer: `features/{feature}/presentation/` (screens/widgets)

2. **State Management:** Use Riverpod with notifier pattern
   - All state changes via notifier providers
   - Never call Firebase directly from UI screens
   - Always handle `Result<T>` (success/failure) from notifier methods

3. **Firebase Integration:**
   - Use DataSource pattern for all Firebase operations
   - Firestore documents follow the schema defined in `/docs/`

4. **UI Components:** Use shared widgets from `lib/shared/widgets/`

5. **Theming:** Use `AppColors` and `AppDimens` from `core/theme/app_theme.dart`
   - No hardcoded colors or spacing values

6. **Error Handling:** Use `Result<T>` pattern

   ```dart
   final result = await _repository.someMethod();
   return result.fold(
     onSuccess: (data) => /* handle success */,
     onFailure: (failure) => /* handle error */,
   );
   ```

7. **Navigation:** Use GoRouter with routes defined in `main.dart`

8. **Code Generation:** After modifying providers or Freezed models
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Checklist Before Committing Changes

- [ ] Read relevant spec in `/docs/` to understand current implementation
- [ ] Follow Clean Architecture layers (data/domain/presentation)
- [ ] Use Riverpod providers (not direct Firebase calls in UI)
- [ ] Handle errors with `Result<T>` pattern
- [ ] Use shared widgets from `lib/shared/widgets/`
- [ ] Apply theming (`AppColors`, `AppDimens`) - no hardcoded values
- [ ] Dispose controllers/focus nodes in `dispose()` method
- [ ] Run `build_runner` if providers/models changed
- [ ] Update spec in `/docs/` if adding new functionality
- [ ] Test the feature flow thoroughly

---

## Important Notes

- Do not generate quick or hacky solutions
- Always prefer scalable solutions
- Keep consistency across all apps
- Agent permissions are defined in each agent's YAML frontmatter
- Keep this file up-to-date when agent configurations change or any other major change
- Use `context7` tools.
- **Read feature specs in `/docs/` before modifying features**
