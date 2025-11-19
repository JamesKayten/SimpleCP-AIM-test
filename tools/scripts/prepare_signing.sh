#!/bin/bash
# Prepare macOS app for code signing and notarization

set -e

echo "========================================="
echo "macOS App Signing & Notarization Prep"
echo "========================================="

APP_BUNDLE=${1:-"build/SimpleCP.app"}
BUNDLE_ID="com.simplecp.macos"
TEAM_ID=${APPLE_TEAM_ID:-"YOUR_TEAM_ID"}

# Check if app bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: App bundle not found at $APP_BUNDLE"
    exit 1
fi

echo "App Bundle: $APP_BUNDLE"
echo "Bundle ID: $BUNDLE_ID"
echo "Team ID: $TEAM_ID"
echo ""

# Create entitlements file
ENTITLEMENTS="build/SimpleCP.entitlements"
cat > "$ENTITLEMENTS" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
</dict>
</plist>
EOF

echo "Created entitlements: $ENTITLEMENTS"

# Create signing script
SIGN_SCRIPT="build/sign_app.sh"
cat > "$SIGN_SCRIPT" << 'EOF'
#!/bin/bash
# Code signing script (requires Apple Developer account)

APP_BUNDLE=$1
IDENTITY=${SIGNING_IDENTITY:-"Developer ID Application"}

echo "Signing app bundle with identity: $IDENTITY"

# Sign all frameworks first
find "$APP_BUNDLE/Contents/Frameworks" -name "*.framework" -o -name "*.dylib" | while read framework; do
    echo "Signing: $framework"
    codesign --force --sign "$IDENTITY" \
        --timestamp \
        --options runtime \
        "$framework"
done

# Sign the main app
echo "Signing main app bundle..."
codesign --force --sign "$IDENTITY" \
    --entitlements "build/SimpleCP.entitlements" \
    --timestamp \
    --options runtime \
    --deep \
    "$APP_BUNDLE"

# Verify signature
echo "Verifying signature..."
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

echo "Signing complete!"
EOF

chmod +x "$SIGN_SCRIPT"
echo "Created signing script: $SIGN_SCRIPT"

# Create notarization script
NOTARIZE_SCRIPT="build/notarize_app.sh"
cat > "$NOTARIZE_SCRIPT" << 'EOF'
#!/bin/bash
# Notarization script (requires Apple Developer account)

APP_BUNDLE=$1
BUNDLE_ID=${2:-"com.simplecp.macos"}
APPLE_ID=${APPLE_ID:-"your@email.com"}
TEAM_ID=${APPLE_TEAM_ID:-"YOUR_TEAM_ID"}

echo "Creating distribution package..."
DIST_ZIP="build/SimpleCP.zip"
ditto -c -k --keepParent "$APP_BUNDLE" "$DIST_ZIP"

echo "Uploading to Apple for notarization..."
xcrun notarytool submit "$DIST_ZIP" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAM_ID" \
    --password "@keychain:AC_PASSWORD" \
    --wait

echo "Stapling notarization ticket..."
xcrun stapler staple "$APP_BUNDLE"

echo "Notarization complete!"
EOF

chmod +x "$NOTARIZE_SCRIPT"
echo "Created notarization script: $NOTARIZE_SCRIPT"

# Create DMG creation script
DMG_SCRIPT="build/create_dmg.sh"
cat > "$DMG_SCRIPT" << 'EOF'
#!/bin/bash
# Create distributable DMG

APP_BUNDLE=$1
VERSION=${2:-"1.0.0"}
DMG_NAME="SimpleCP-${VERSION}.dmg"

echo "Creating DMG: $DMG_NAME"

# Create temporary DMG directory
DMG_DIR="build/dmg_temp"
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy app to DMG directory
cp -R "$APP_BUNDLE" "$DMG_DIR/"

# Create Applications symlink
ln -s /Applications "$DMG_DIR/Applications"

# Create DMG
hdiutil create -volname "SimpleCP" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "build/$DMG_NAME"

# Cleanup
rm -rf "$DMG_DIR"

echo "DMG created: build/$DMG_NAME"
EOF

chmod +x "$DMG_SCRIPT"
echo "Created DMG script: $DMG_SCRIPT"

# Create README for signing
cat > "build/SIGNING_README.md" << EOF
# Code Signing & Notarization Instructions

## Prerequisites

1. Apple Developer Account
2. Developer ID Application certificate installed
3. App-specific password for notarization

## Setup

1. Set environment variables:
\`\`\`bash
export SIGNING_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
export APPLE_ID="your@email.com"
export APPLE_TEAM_ID="YOUR_TEAM_ID"
\`\`\`

2. Store app-specific password in keychain:
\`\`\`bash
xcrun notarytool store-credentials "AC_PASSWORD" \
    --apple-id "$APPLE_ID" \
    --team-id "$APPLE_TEAM_ID"
\`\`\`

## Signing Process

1. Sign the app:
\`\`\`bash
./build/sign_app.sh "$APP_BUNDLE"
\`\`\`

2. Notarize the app:
\`\`\`bash
./build/notarize_app.sh "$APP_BUNDLE" "$BUNDLE_ID"
\`\`\`

3. Create DMG:
\`\`\`bash
./build/create_dmg.sh "$APP_BUNDLE" "1.0.0"
\`\`\`

## Verification

Verify the signature:
\`\`\`bash
spctl -a -t exec -vv "$APP_BUNDLE"
\`\`\`

Check notarization status:
\`\`\`bash
xcrun stapler validate "$APP_BUNDLE"
\`\`\`
EOF

echo ""
echo "Signing preparation complete!"
echo ""
echo "Next steps:"
echo "1. Review build/SIGNING_README.md"
echo "2. Set up your Apple Developer credentials"
echo "3. Run ./build/sign_app.sh $APP_BUNDLE"
echo "4. Run ./build/notarize_app.sh $APP_BUNDLE"
echo "5. Run ./build/create_dmg.sh $APP_BUNDLE"
echo ""
