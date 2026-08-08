# Codex Project Guide

## Project

`flutter_love_journal` is a Flutter app for a love journal experience. Main app code lives in `lib/`, JSON data and images live in `assets/`, and design handoff material lives in `docs/designs/`.

## Context Entry Points

When starting a fresh thread, read these files before making product or architecture decisions:

- `.context/love-journal-context/AGENTS.md` for the rules governing shared mobile/backend context.
- `.context/love-journal-context/context/current-context.md` for cross-project status and locked decisions.
- `.context/love-journal-context/context/domain-model.md` and `context/integration-status.md` for shared contracts and integration state.
- `.context/love-journal-context/plans/managed-balanced-backend.md` for the decision-complete standalone backend implementation plan.
- `docs/current-context.md` for the short client status and module index.
- `docs/context/README.md` and only the relevant file under `docs/context/` for detailed Flutter architecture, module state, implementation decisions, and verification notes.
- `docs/designs/love-journal-current-ui-ux.md` for the current app UI/UX source of truth.
- `docs/designs/love-journal-implementation-spec.md` for the broader implementation specification.
- `docs/designs/love-journal-time-management-handoff.html` for the editable Time/memory module design.
- `docs/designs/love-journal-auth-handoff.html` for the implemented auth presentation handoff; read `docs/context/auth.md` for runtime integration status.
- `docs/designs/love-journal-design-tokens.json` when changing visual tokens, spacing, colors, radii, or typography.

## Commands

- Initialize shared context: `git submodule update --init --recursive`
- Install dependencies: `flutter pub get`
- Static analysis: `flutter analyze`
- Tests: `flutter test`
- Web smoke build: `flutter build web`

Run `flutter pub get` after dependency or asset changes. Prefer `flutter analyze` and `flutter test` before finishing code changes.

## Code Style

- Follow the existing feature-first structure under `lib/src/features/`.
- Keep shared infrastructure under `lib/src/core/` and app-level wiring under `lib/src/app/`.
- Use Riverpod providers/controllers for state orchestration. Prefer immutable state models with `copyWith` over mutating objects in place.
- Keep API, JSON asset loading, persistence, repositories, domain entities, and presentation widgets separated by layer.
- Route through GoRouter and the existing navigation shell. Do not add ad-hoc tab state for primary navigation.
- Keep UI components small and reusable when they are shared between screens.
- Keep user-facing copy warm, concise, and consistent with the journal theme.
- Keep UI/UX changes aligned with the docs in `docs/designs/`, especially the current UI/UX source of truth.
- Update the shared context repository when a change affects backend contracts, shared domain rules, synchronization, auth, media ownership, Places, notifications, chat, or calls.
- Do not duplicate shared context Markdown into this repository. Update the pinned submodule commit instead.
- Keep generated build output, local IDE files, and machine-specific Flutter files out of Git.

## Cloud Notes

Codex Cloud checks out this repository in a Linux container. Use `.codex/cloud-setup.sh` as the setup script for the Codex Cloud environment, or copy its contents into the environment setup field. The GitHub connection must also have access to the private `lehung1006/love-journal-context` submodule.

Before using Codex Cloud, push the latest local commits so the cloud thread can read the same code and docs. See `docs/codex-cloud.md` for setup notes.
