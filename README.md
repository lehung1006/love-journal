# Love Journal

A Flutter app for storing love memories, letters, places, and anniversary moments.

## Getting Started

Clone with the shared context submodule:

```bash
git clone --recurse-submodules https://github.com/lehung1006/love-journal.git
```

For an existing checkout:

```bash
git submodule update --init --recursive
```

Install dependencies:

```bash
flutter pub get
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run the app:

```bash
flutter run
```

The journal is protected by the Auth gate. For local Auth configuration:

```powershell
Copy-Item config/auth.dev.example.json config/auth.dev.json
flutter run --dart-define-from-file=config/auth.dev.json
```

Fill `config/auth.dev.json` with Firebase/backend values for real login. For a
debug-only UI run before those services exist, set `AUTH_DEV_BYPASS` to `true`
and use Email OTP `123456`. The local file is ignored by Git. See
`docs/context/auth.md` for the complete setup and provisional backend contract.

## Codex Cloud

This project includes Codex Cloud setup notes:

- Project guidance: `AGENTS.md`
- Cloud setup script: `.codex/cloud-setup.sh`
- Setup checklist: `docs/codex-cloud.md`

## Shared Context

Cross-project product, domain, backend, and integration context is pinned from
the private `lehung1006/love-journal-context` repository at:

```text
.context/love-journal-context
```

Read its `AGENTS.md` and `context/current-context.md` before making changes that
affect both the Flutter client and backend. The approved standalone backend plan
is `plans/managed-balanced-backend.md` inside the submodule.
