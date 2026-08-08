# Codex Cloud Setup

Use this checklist after the project is pushed to GitHub.

## 1. Push The Repository

Create a GitHub repository, then push this project. Codex Cloud needs access to the GitHub repository because cloud tasks run from a remote checkout.

## 2. Create The Codex Environment

Open:

https://chatgpt.com/codex/settings/environments

Create a new environment for this repository. Use the setup script from `.codex/cloud-setup.sh`.

The GitHub connection must have read access to both:

- `lehung1006/love-journal`
- `lehung1006/love-journal-context`

The second repository is private and is consumed as a Git submodule.

## 3. Recommended Environment Settings

- Setup script: contents of `.codex/cloud-setup.sh`
- Agent internet access: off by default; enable only if a task needs live internet
- Dependency/network allowlist during setup: allow GitHub and package dependency hosts as needed
- Branch: use `main` or the active feature branch

The setup script initializes `.context/love-journal-context` before installing
Flutter dependencies. A submodule authentication failure means the Codex
GitHub connection does not yet have access to the context repository.

## 4. Start A Cloud Task

From the Codex app, create a new thread and choose `Cloud`, then select this environment.

From the CLI:

```bash
codex login
codex cloud
```

Or run a direct task:

```bash
codex cloud exec --env ENV_ID "Run flutter analyze and fix any issues."
```

## 5. Validation Commands

Ask Codex Cloud to run:

```bash
git submodule status
python .context/love-journal-context/scripts/validate_context.py
flutter pub get
flutter analyze
flutter test
```

For a lightweight build check:

```bash
flutter build web
```
