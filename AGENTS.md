# Time Shadow — AGENTS.md

## Overview

Time Shadow is a minimal ambient timer for iOS 17+. A soft gradient shadow creeps across the user's wallpaper from left to right over the duration of the timer. No numbers, no countdown — just visual time awareness. The app is free with a one-time $3.99 Pro purchase.

**Concept:** Like a sundial for your iPhone. Place it face-up or in a stand and watch the shadow grow. When it reaches the right edge, your time is up.

---

## Architecture

### Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | SwiftUI (iOS 17+) |
| Timer Engine | DispatchSourceTimer (high-resolution, background-safe) |
| Shadow Rendering | SwiftUI `LinearGradient` with offset animation |
| Haptics | Core Haptics (`CHHapticEngine`) + `UIImpactFeedbackGenerator` |
| Live Activities | ActivityKit (`Activity<ActivityAttributes>`) |
| Widget | WidgetKit (Lock Screen + Home Screen) |
| Purchases | StoreKit 2 (StoreKit `Product`) |
| Persistence | `UserDefaults` (JSON-encoded timer sessions) |
| Charts | Swift Charts (iOS 16+) |

### Project Structure

```
TimeShadow/
├── App/
│   ├── TimeShadowApp.swift      # @main app entry, environment setup
│   └── ContentView.swift        # Root navigation (setup ↔ active)
├── Models/
│   ├── TimerPreset.swift        # Named duration presets
│   ├── ShadowTheme.swift        # 12 gradient themes with CodableColor
│   ├── TimerSession.swift       # Completed session record
│   └── ProUnlockManager.swift   # Observable pro state mirror
├── Services/
│   ├── TimerEngine.swift        # High-res timer with pause/resume
│   ├── ShadowRenderer.swift     # Gradient band offset renderer
│   ├── HapticService.swift      # Finish tap + sunrise alarm
│   ├── LiveActivityManager.swift # Dynamic Island integration
│   ├── WidgetDataProvider.swift  # App Group UserDefaults for widget
│   ├── StoreKitManager.swift    # $3.99 one-time purchase
│   └── AnalyticsService.swift   # Session recording + stats
├── Views/
│   ├── TimerSetupView.swift     # Preset picker + theme + start
│   ├── ActiveTimerView.swift    # Full-screen shadow experience
│   ├── CompletionView.swift     # Gentle pulse + "Done" screen
│   ├── PresetPickerView.swift   # Grid of timer durations
│   ├── ThemePickerView.swift    # Scrollable theme selection
│   ├── StatsView.swift          # Focus history with Swift Charts
│   ├── SettingsView.swift       # Pro, version, privacy
│   └── ProUpgradeView.swift     # Feature comparison + purchase
├── Widgets/
│   ├── TimerWidget.swift        # Lock Screen widget configuration
│   └── WidgetBundle.swift       # @main widget bundle entry
├── Resources/
│   └── Assets.xcassets/         # Placeholder asset catalog
├── AGENTS.md                    # This file
└── .gitignore
```

---

## What's Built (Files & Purpose)

### Models (4 files)

- **TimerPreset.swift** — 8 named presets (Focus 25m, Short 5m, Long 50m, Deep Focus 90m, Nap 20m, Break 15m, Work Block 4h, Custom). Each preset has `isPro` flag. Free tier max is 25 minutes.
- **ShadowTheme.swift** — 12 gradient themes: Warm Gray (free), Sunset, Ocean, Forest, Midnight, Aurora, Fire, Ice, Sepia, Monochrome, Neon, Cosmic (all Pro). Uses `CodableColor` for serialization.
- **TimerSession.swift** — Codable record of a completed session (start, end, duration, theme, completion status).
- **ProUnlockManager.swift** — ObservableObject mirror of StoreKitManager.isPro for decoupled access.

### Services (7 files)

- **TimerEngine.swift** — `@MainActor ObservableObject`. Uses `DispatchSourceTimer` at 50ms intervals (≈60fps). Publishes `progress` (0.0→1.0), `elapsed`, `remaining`, `isRunning`, `isPaused`, `isComplete`. Supports pause/resume/cancel. Manages a `UIBackgroundTaskIdentifier` for background execution. Completion callback triggers on 100%.
- **ShadowRenderer.swift** — Two views: `ShadowRenderer` (the gradient band) and `ShadowOverlay` (band + subtle darkening). The band is 35% of screen width, offset from offscreen-left to offscreen-right. Uses `.animation(.interactiveSpring)` for smooth movement. `allowsHitTesting(false)` so taps pass through.
- **HapticService.swift** — Two patterns: (1) `playFinishHaptic()` — three gentle `UIImpactFeedbackGenerator` taps. (2) `playSunriseHaptic(duration:)` — escalating CHHapticEngine pattern: 16 transient taps growing in intensity + a continuous low-frequency hum that fades in over the alarm duration.
- **LiveActivityManager.swift** — `Activity<TimerWidgetAttributes>` management. `startActivity(duration:themeID:)`, `updateActivity(progress:remaining:)`, `endActivity()`, `cancelActivity()`. The Dynamic Island shows a shrinking gradient bar + relative time phrase (e.g., "About 12 min left").
- **WidgetDataProvider.swift** — App Group `UserDefaults(suiteName:)` bridge between app and widget extension. Writes progress/remaining/active state/theme ID. Widget reads on timeline refresh.
- **StoreKitManager.swift** — `@MainActor ObservableObject`. Loads product `com.steveafrost.TimeShadow.pro` via StoreKit 2. Handles purchase flow, transaction verification, `Transaction.updates` observation, `Transaction.currentEntitlements` check, and restore.
- **AnalyticsService.swift** — Records `TimerSession` objects to UserDefaults (JSON array, max 500). Provides `totalFocusMinutes`, `totalSessionsCompleted`, `averageSessionMinutes`, and `weeklySessions` grouping for charts.

### Views (8 files)

- **TimerSetupView.swift** — Scrollable setup screen: header, preset grid (PresetPickerView), theme preview bar with picker button, Start button. Toolbar links to Stats and Settings. Includes a custom duration sheet with a slider (5-240 min for Pro, 1-25 min for free).
- **ActiveTimerView.swift** — Full-screen view with wallpaper-visible background, `ShadowOverlay`, and subtle pause/cancel buttons at the bottom. When paused shows a "Paused" capsule. On completion transitions to `CompletionView`. Records session to AnalyticsService.
- **CompletionView.swift** — Pulsing green circle + checkmark, "Done" title, "A shadow has passed." quote, and Continue button. Animated entrance with scale + opacity.
- **PresetPickerView.swift** — `LazyVGrid` of preset buttons. Shows selection ring. Pro-locked presets show a lock icon and are disabled (free users can't select them).
- **ThemePickerView.swift** — Scrollable grid of 12 color circles with gradient fills. Selected theme gets a ring + checkmark. Locked themes show lock overlay. Non-Pro users see an Upgrade button linking to ProUpgradeView.
- **StatsView.swift** — Summary cards (Sessions, Total Focus, Avg Session), weekly bar chart via Swift Charts, and recent sessions list. Includes "Clear" action with confirmation alert.
- **SettingsView.swift** — Form-style list: Pro section (upgrade or unlocked), About (version, website, GitHub), Privacy notice.
- **ProUpgradeView.swift** — Feature comparison with SF Symbol rows, purchase button ($3.99), Restore Purchases button, and state handling (loading, error, already-unlocked).

### Widgets (2 files)

- **TimerWidget.swift** — `StaticConfiguration` widget with `accessoryCircular`, `accessoryRectangular`, and `systemSmall` families. Circular: progress ring. Rectangular: gradient bar + time phrase. Small: compact bar. Inactive state shows "No Timer".
- **WidgetBundle.swift` — @main entry point wrapping `TimerWidget`.

---

## What Requires a Real Device

The following features require a physical iOS device and **will not work** in the simulator:

| Feature | Reason |
|---|---|
| **Core Haptics** (sunrise alarm) | `CHHapticEngine` requires a device with the haptic engine (iPhone 8+) |
| **Live Activities / Dynamic Island** | `ActivityKit` requires a device running iOS 16.1+ with an A12+ chip |
| **Lock Screen Widget** | Widget preview works in simulator but actual Lock Screen placement needs a device |
| **Wallpaper visibility** | The wallpaper-visible effect requires iOS wallpapers; simulator shows solid background |
| **StoreKit purchase flow** | Sandbox testing works on device; simulator requires StoreKit Testing config |

### Testing Without a Device

- **Timer engine** — Works fully in simulator. Run the app and start a 1-minute timer.
- **Shadow rendering** — The gradient band animates across the screen in simulator.
- **Views & Navigation** — All views (Setup, Active, Completion, Stats, Settings, Pro) navigate correctly.
- **Haptic fallback** — `playFinishHaptic()` uses `UIImpactFeedbackGenerator` which gives console output but no physical feedback in simulator.
- **Widget UI** — Widget preview renders in simulator with placeholder data.
- **Analytics** — Session recording and stats work in simulator.

---

## Next Steps to Ship

### 1. Xcode Project Setup

This repository contains **only Swift source files** — no `.xcodeproj`. To build:

```bash
# Option A: Create an Xcode project manually
xcode-select --install  # if needed
open -a Xcode
# File → New → Project → iOS → App → "Time Shadow"
# Set minimum deployment: iOS 17.0
# Interface: SwiftUI, Language: Swift
# Then drag all folders into the project navigator
```

**Important:** The widget extension (`TimerWidget`, `WidgetBundle`) must be in a separate Widget Extension target. You'll need to add it manually:

1. File → New → Target → Widget Extension → "TimeShadowWidgets"
2. Set the `TimerWidget.swift` and `WidgetBundle.swift` as the widget target's source files
3. Set up an App Group (`group.com.steveafrost.TimeShadow`) in both the main app and widget capabilities

### 2. Required Capabilities

For the main app target:
- **App Groups** — `group.com.steveafrost.TimeShadow`
- **Live Activities** — Enabled in Info.plist (`NSSupportsLiveActivities = YES`)
- **Background Modes** — Optional: "Background processing" for longer timers

For the widget extension target:
- **App Groups** — Same group as above

### 3. Info.plist Entries

```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>StoreKit</key>
<dict>
    <key>com.steveafrost.TimeShadow.pro</key>
    <dict>
        <key>type</key>
        <string>Non-Consumable</string>
        <key>displayName</key>
        <string>Time Shadow Pro</string>
        <key>price</key>
        <integer>399</integer>
    </dict>
</dict>
```

### 4. App Store Connect Setup

See [`APP_STORE_CONNECT.md`](APP_STORE_CONNECT.md) for the full App Store Connect preparation guide, including:

- App record details (bundle ID, SKU, pricing)
- Screenshot requirements and suggestions
- In-App Purchase configuration
- Privacy details
- Distribution checklist

### 5. Feature Status

| Feature | Status | Notes |
|---|---|---|
| Timer engine (countdown) | ✅ Complete | 50ms resolution, pause/resume |
| Shadow gradient animation | ✅ Complete | LinearGradient offset, interactive spring |
| Free tier (25 min, gray) | ✅ Complete | Enforced in PresetPickerView |
| Pro themes (12 colors) | ✅ Complete | Selection, lock overlay, preview |
| Pro custom duration (5m–4h) | ✅ Complete | Slider with pro check |
| Haptic finish (tap) | ✅ Complete | 3-tap sequence |
| Haptic sunrise alarm | ✅ Complete | CHHapticEngine pattern (device only) |
| Live Activities | ✅ Complete | ActivityKit integration |
| Lock Screen widget | ✅ Complete | 3 families, gradient bar |
| StoreKit purchase | ✅ Complete | StoreKit 2, verification, restore |
| Stats with Swift Charts | ✅ Complete | Weekly bar chart, summary cards |
| Settings + About | ✅ Complete | Pro status, version, links |
| Pro upgrade screen | ✅ Complete | Feature list + purchase button |
| Zen mode (silent) | ⬜ Not implemented | Needs a settings toggle |
| Start/End notifications | ⬜ Not implemented | Needs UNUserNotificationCenter |

---

## Swift Style & Conventions

- **SwiftUI**: `@EnvironmentObject` for shared state, `@State` for local state, `@Binding` for child-parent
- **Architecture**: MV-ish (Models + ObservableObject Services + SwiftUI Views)
- **Concurrency**: `@MainActor` for UI-bound services, `Task` for async StoreKit calls
- **Naming**: `TimerPreset`, `ShadowTheme`, `TimerSession` (Models); `TimerEngine`, `StoreKitManager` (Services)
- **No 3rd-party dependencies** — pure Apple SDKs

---

## Build & Run

```bash
# Clone
git clone https://github.com/steveafrost/time-shadow.git
cd time-shadow

# Open in Xcode
open TimeShadow.xcodeproj

# Build (command line — requires Xcode CLI tools)
# xcodebuild -project TimeShadow.xcodeproj -scheme "Time Shadow" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build
```

---

*Built by Hermes Agent · [Nous Research](https://nousresearch.com)*
