# iOS release with an App Store Connect API key (sourced by scripts/build.sh, not executed).
#
# `flutter build ipa` cannot sign without an Apple account signed in to Xcode. Here Flutter only
# prepares the project (`flutter build ios --config-only`); xcodebuild then archives and exports
# with the API key and -allowProvisioningUpdates, which creates on demand everything signing needs
# in team 6NUB622B7R: the cloud-managed distribution certificate, the identifier of the
# notification extension, the OneSignal app group and the provisioning profiles.
#
# Key: Doppler soe-mobile (stg and prd) ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_P8_BASE64 (role Admin),
# restored to keys/AuthKey_<id>.p8 (gitignored) when missing.

IOS_TEAM_ID="6NUB622B7R"
IOS_ARCHIVE="build/ios/archive/Runner.xcarchive"
IOS_EXPORT_DIR="build/ios/ipa"

# Sets ASC_KEY_ID, ASC_ISSUER_ID and ASC_KEY_PATH from Doppler config $1; never prints the key.
load_asc_key() {
  local config="$1"
  ASC_KEY_ID=$(doppler_secret ASC_KEY_ID "$config")
  ASC_ISSUER_ID=$(doppler_secret ASC_ISSUER_ID "$config")
  if [ -z "$ASC_KEY_ID" ] || [ -z "$ASC_ISSUER_ID" ]; then
    echo "Error: ASC_KEY_ID / ASC_ISSUER_ID missing in Doppler $DOPPLER_PROJECT/$config." >&2
    return 1
  fi
  ASC_KEY_PATH="$PWD/keys/AuthKey_${ASC_KEY_ID}.p8"
  if [ ! -f "$ASC_KEY_PATH" ]; then
    echo "Restoring the App Store Connect API key from Doppler $DOPPLER_PROJECT/$config..."
    (umask 077 && mkdir -p keys && doppler_secret ASC_KEY_P8_BASE64 "$config" | base64 -d > "$ASC_KEY_PATH")
    [ -s "$ASC_KEY_PATH" ] || { echo "Error: ASC_KEY_P8_BASE64 missing in Doppler." >&2; rm -f "$ASC_KEY_PATH"; return 1; }
  fi
}

asc_auth_flags() {
  ASC_AUTH_FLAGS=(
    -allowProvisioningUpdates
    -authenticationKeyPath "$ASC_KEY_PATH"
    -authenticationKeyID "$ASC_KEY_ID"
    -authenticationKeyIssuerID "$ASC_ISSUER_ID"
  )
}

# Archives the app prepared by `flutter build ios --config-only`.
ios_archive() {
  asc_auth_flags
  rm -rf "$IOS_ARCHIVE"
  xcodebuild archive \
    -workspace ios/Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$IOS_ARCHIVE" \
    DEVELOPMENT_TEAM="$IOS_TEAM_ID" \
    "${ASC_AUTH_FLAGS[@]}" \
    -quiet
}

# Exports the archive for App Store Connect. $1 = upload (sent to TestFlight) or export (IPA kept
# in build/ios/ipa, nothing sent).
ios_export() {
  local destination="$1"
  local options="build/ios/ExportOptions.plist"
  asc_auth_flags
  mkdir -p build/ios
  cat > "$options" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>$destination</string>
  <key>teamID</key><string>$IOS_TEAM_ID</string>
  <key>signingStyle</key><string>automatic</string>
  <key>uploadSymbols</key><true/>
  <key>manageAppVersionAndBuildNumber</key><false/>
</dict>
</plist>
EOF
  rm -rf "$IOS_EXPORT_DIR"
  xcodebuild -exportArchive \
    -archivePath "$IOS_ARCHIVE" \
    -exportOptionsPlist "$options" \
    -exportPath "$IOS_EXPORT_DIR" \
    "${ASC_AUTH_FLAGS[@]}"
}
