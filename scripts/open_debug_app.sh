#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

"$ROOT_DIR/scripts/xcode_build.sh"

APP_MATCHES=()
while IFS= read -r app_path; do
  APP_MATCHES+=("$app_path")
done < <(
  find "$HOME/Library/Developer/Xcode/DerivedData" \
    -path '*MuniRename*/Build/Products/Debug/MuniRename.app' \
    -not -path '*/Index.noindex/*'
)

if [[ ${#APP_MATCHES[@]} -eq 0 ]]; then
  echo "Aucune app construite trouvee dans DerivedData." >&2
  exit 1
fi

APP_PATH="$(ls -td "${APP_MATCHES[@]}" | head -n 1)"

if [[ ! -d "$APP_PATH/Contents/MacOS" ]]; then
  echo "Bundle invalide (Contents/MacOS absent): $APP_PATH" >&2
  exit 1
fi

if ! find "$APP_PATH/Contents/MacOS" -maxdepth 1 -type f -perm -111 | grep -q .; then
  echo "Bundle invalide (aucun executable dans Contents/MacOS): $APP_PATH" >&2
  exit 1
fi

echo "Ouverture: $APP_PATH"
if [[ "${NO_OPEN:-0}" == "1" ]]; then
  echo "NO_OPEN=1 -> ouverture sautee."
  exit 0
fi

open "$APP_PATH"
