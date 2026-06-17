# Time Shadow

A minimal ambient timer for iOS 17+. A soft gradient shadow creeps across the screen so you can feel time passing without staring at a countdown.

## Build locally

```bash
# Regenerate the Xcode project after changing project.yml
xcodegen generate --spec project.yml

# Compile app + widget extension without signing
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project TimeShadow.xcodeproj \
  -target TimeShadow \
  -configuration Release \
  -sdk iphoneos \
  CODE_SIGNING_ALLOWED=NO build
```

Open `TimeShadow.xcodeproj` in Xcode 15+ (or newer), select the `TimeShadow` scheme, choose your team, and run on a physical device.

## TestFlight setup

1. In Apple Developer, create these identifiers/capabilities:
   - App ID: `com.steveafrost.TimeShadow`
   - Widget extension App ID: `com.steveafrost.TimeShadow.Widgets`
   - App Group: `group.com.steveafrost.TimeShadow`
   - Capabilities: App Groups for both targets, Live Activities for the app target.
2. In App Store Connect, create the app record for bundle ID `com.steveafrost.TimeShadow`.
3. Create the non-consumable IAP: `com.steveafrost.TimeShadow.pro`.
4. In Xcode, set your Development Team on both targets and let Xcode manage signing.
5. Product → Archive → Distribute App → App Store Connect → Upload.

## What to verify on device

- Start, pause, resume, cancel, and complete a short timer.
- Completion notification appears when the app is backgrounded.
- Zen Mode suppresses haptics/sound for Pro users.
- Live Activity appears on Lock Screen/Dynamic Island.
- Lock Screen/Home Screen widget reads active timer progress.
- Core Haptics sunrise alarm plays on a supported iPhone.
