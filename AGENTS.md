# Codex Project Guide

## Project

`flutter_love_journal` is a Flutter app for a love journal experience. Main app code lives in `lib/`, JSON data and images live in `assets/`, and design handoff material lives in `docs/designs/`.

## Commands

- Install dependencies: `flutter pub get`
- Static analysis: `flutter analyze`
- Tests: `flutter test`
- Web smoke build: `flutter build web`

Run `flutter pub get` after dependency or asset changes. Prefer `flutter analyze` and `flutter test` before finishing code changes.

## Code Style

- Follow the existing feature-first structure under `lib/src/features/`.
- Keep UI components small and reusable when they are shared between screens.
- Keep user-facing copy warm, concise, and consistent with the journal theme.
- Keep generated build output, local IDE files, and machine-specific Flutter files out of Git.

## Cloud Notes

Codex Cloud checks out this repository in a Linux container. Use `.codex/cloud-setup.sh` as the setup script for the Codex Cloud environment, or copy its contents into the environment setup field.
