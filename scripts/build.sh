#!/usr/bin/env bash
set -euo pipefail

# Builds one of the two SOE apps for release.
#
# Usage:
#   ./scripts/build.sh test            # « SOE Test » Android App Bundle (Play)
#   ./scripts/build.sh prod            # « SOE » Android App Bundle (Play)
#   ./scripts/build.sh test --apk      # « SOE Test » APK (direct install)
#   ./scripts/build.sh prod --ios      # « SOE » iOS IPA (App Store Connect)
#
#   test | stg  -> « SOE Test », cm.soe.mobile.test, https://api.jeteste.site
#   prod | prd  -> « SOE »,      cm.soe.mobile,      https://api.solutionofeducation.com
#
# Secrets come from Doppler (project soe-mobile, config stg or prd). The version is read from
# pubspec.yaml; override with BUILD_NAME=1.2.0 BUILD_NUMBER=42 ./scripts/build.sh prod
# Set SKIP_CLEAN=1 to skip `flutter clean` (faster, when switching apps is not needed).

cd "$(dirname "$0")/.."
# shellcheck source=scripts/lib/app_env.sh
source scripts/lib/app_env.sh

usage() {
  echo "Usage: ./scripts/build.sh <test|stg|prod|prd> [--android|--apk|--ios]" >&2
  exit 1
}

ENV_NAME="${1:-}"
PLATFORM="${2:---android}"

case "$ENV_NAME" in
  test | stg) CONFIG="stg"; TARGET="lib/main_staging.dart" ;;
  prod | prd) CONFIG="prd"; TARGET="lib/main_prod.dart" ;;
  *) usage ;;
esac

case "$PLATFORM" in
  --android) BUILD_TYPE="appbundle"; OUTPUT="build/app/outputs/bundle/release/app-release.aab" ;;
  --apk) BUILD_TYPE="apk"; OUTPUT="build/app/outputs/flutter-apk/app-release.apk" ;;
  --ios) BUILD_TYPE="ipa"; OUTPUT="build/ios/ipa/*.ipa" ;;
  *) usage ;;
esac

# ── Version (pubspec.yaml: version: X.Y.Z+N) ──
PUBSPEC_VERSION=$(grep '^version:' pubspec.yaml | head -1 | sed 's/version: //')
BUILD_NAME="${BUILD_NAME:-${PUBSPEC_VERSION%%+*}}"
BUILD_NUMBER="${BUILD_NUMBER:-${PUBSPEC_VERSION##*+}}"

set_identity "$CONFIG"
load_app_secrets "$CONFIG"
dart_defines "$CONFIG"

echo "────────────────────────────────────"
echo "  App:        $APP_NAME ($APP_ID)"
echo "  API:        $API_BASE_URL"
echo "  Doppler:    $DOPPLER_PROJECT / $CONFIG"
echo "  Version:    $BUILD_NAME ($BUILD_NUMBER)"
echo "  Output:     $BUILD_TYPE"
echo "────────────────────────────────────"

write_identity_files
if [ "$BUILD_TYPE" != "ipa" ]; then
  restore_upload_key "$CONFIG"
fi

# dart-define values and the app identity are cached by the previous build.
if [ "${SKIP_CLEAN:-0}" != "1" ]; then
  flutter clean
fi
flutter pub get
dart run slang # lib/i18n/*.g.dart are generated and gitignored

flutter build "$BUILD_TYPE" --release \
  --target="$TARGET" \
  --build-name="$BUILD_NAME" \
  --build-number="$BUILD_NUMBER" \
  "${DART_DEFINES[@]}"

echo ""
echo "Build complete: $APP_NAME ($APP_ID)"
echo "Output: $OUTPUT"
