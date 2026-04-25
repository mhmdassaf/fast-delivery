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
- `Flutter-developer.md` - Build Flutter features
- `Firebase-developer.md` - Firestore schema & Cloud Functions (Backend)
- `Code-reviewer.md` - Optimize existing code
- `Designer.md` - UI/UX suggestions only

## Key Conventions
- Business logic must stay out of UI
- No hardcoded values
- Use null safety and strong typing
- Code must be modular and reusable
- Write readable and maintainable code

## Important Notes
- Do not generate quick or hacky solutions
- Always prefer scalable solutions
- Keep consistency across all apps
- Agent permissions are defined in each agent's YAML frontmatter
- Keep this file up-to-date when agent configurations change or any other major change
- Use `context7` tools.
