#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
    git clone https://github.com/flutter/flutter.git --branch "$FLUTTER_CHANNEL" --depth 1 "$FLUTTER_HOME"
  fi

  export PATH="$FLUTTER_HOME/bin:$PATH"
elif [ -x "$FLUTTER_HOME/bin/flutter" ]; then
  export PATH="$FLUTTER_HOME/bin:$PATH"
fi

mkdir -p "$PUB_CACHE"
export PUB_CACHE

if [ -d "$FLUTTER_HOME/bin" ] && ! grep -q "$FLUTTER_HOME/bin" "$HOME/.bashrc" 2>/dev/null; then
  echo "export PATH=\"$FLUTTER_HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
fi

flutter config --no-analytics
flutter --version
flutter pub get
