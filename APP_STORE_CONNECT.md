# App Store Connect Setup — Time Shadow

## App Record
- **Name:** Time Shadow
- **Bundle ID:** com.steveafrost.TimeShadow
- **SKU:** time-shadow-2026
- **Apple ID:** (leave blank until created)
- **Price:** Free with $3.99 one-time purchase
- **Category:** Productivity
- **Subcategory:** (optional)
- **Age Rating:** 4+
- **Privacy URL:** https://straightcodes.com/privacy (or your privacy page)
- **Support URL:** (your support URL)

## App Icon
- Placeholder icon included in Assets.xcassets/AppIcon.appiconset/
- Replace with a real 1024×1024 PNG before submission

## Screenshots (required for TestFlight)
- Need at least 1 screenshot per device size
- 6.7" iPhone: 1290×2796 px
- 6.5" iPhone: 1242×2688 px
- 5.5" iPhone: 1242×2208 px
- iPad Pro: 2048×2732 px (optional for iPhone-only app)

Suggested screenshots:
1. Timer setup view with preset picker
2. Active timer with shadow creeping across wallpaper
3. Theme picker showing gradient options
4. Lock Screen widget preview
5. Stats view showing focus time history

## In-App Purchases
- **Reference Name:** Time Shadow Pro
- **Product ID:** com.steveafrost.TimeShadow.pro
- **Type:** Non-Consumable
- **Price:** $3.99
- **Display Name:** Time Shadow Pro
- **Description:** Unlock all themes, custom durations, Live Activities, and focus stats

## App Privacy
- No data collection
- All processing on-device
- No analytics SDKs
- Privacy manifest required: indicate NO data collected

## TestFlight Notes
- Add your device UDID to the provisioning profile
- Ensure Family Controls (not needed for this app)
- Test Live Activities on a physical device (not in simulator)
- Test Core Haptics on a physical device
- Test Lock Screen widget after adding to home screen

## Build Settings
- Deployment target: iOS 17.0
- Device family: iPhone & iPad
- Swift version: 5

## Distribution Checklist
- [ ] Create app record in App Store Connect
- [ ] Set pricing and availability
- [ ] Upload screenshots
- [ ] Fill in privacy details
- [ ] Add App Icon (1024×1024)
- [ ] Create IAP in App Store Connect
- [ ] Test on physical device
- [ ] Archive and upload via Xcode
