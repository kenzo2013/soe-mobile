#!/usr/bin/env bash
set -euo pipefail

# Runs the app on a device (debug), with the identity and the API of the chosen config.
#
# Usage:
#   ./scripts/run.sh            # dev: « SOE Test » identity, local Rails server via env/dev.env
#   ./scripts/run.sh stg        # « SOE Test », https://api.jeteste.site (Doppler soe-mobile/stg)
#   ./scripts/run.sh prd        # « SOE »,      https://api.solutionofeducation.com (soe-mobile/prd)
#   ./scripts/run.sh dev -d <device-id>   # extra arguments go to `flutter run`
#
# Development runs against the LOCAL server through a tunnel (env/dev.env, see
# env/example.env): never create accounts or data on staging or production. stg and prd are
# for checking a release candidate only.

cd "$(dirname "$0")/.."
# shellcheck source=scripts/lib/app_env.sh
source scripts/lib/app_env.sh

CONFIG="${1:-dev}"
[ $# -gt 0 ] && shift

set_identity "$CONFIG"
write_identity_files
echo "Running $APP_NAME ($APP_ID) with config $CONFIG"

if [ "$CONFIG" == "dev" ]; then
  if [ ! -f env/dev.env ]; then
    echo "Error: env/dev.env is missing. Copy env/example.env and set your tunnel URL." >&2
    exit 1
  fi
  flutter run --target=lib/main_dev.dart --dart-define-from-file=env/dev.env "$@"
else
  load_app_secrets "$CONFIG"
  dart_defines "$CONFIG"
  TARGET="lib/main_prod.dart"
  [ "$CONFIG" == "stg" ] && TARGET="lib/main_staging.dart"
  flutter run --target="$TARGET" "${DART_DEFINES[@]}" "$@"
fi
