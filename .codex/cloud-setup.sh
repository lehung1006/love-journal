#!/usr/bin/env bash
set -euo pipefail

FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -d "$FLUTTER_HOME/bin" ]; then
    git clone https://github.com/flutter/flutter.git --branch stable --depth 1 "$FLUTTER_HOME"
  fi

  export PATH="$FLUTTER_HOME/bin:$PATH"
fi

if ! grep -q "$FLUTTER_HOME/bin" "$HOME/.bashrc" 2>/dev/null; then
  echo "export PATH=\"$FLUTTER_HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
fi

flutter config --no-analytics
flutter pub get

