
#!/usr/bin/env bash
set -e

if ! command -v flutter >/dev/null 2>&1; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
fi

cd frontend
flutter pub get
flutter build web --release
