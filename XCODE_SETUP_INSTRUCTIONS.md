# Share Extension Setup Instructions

## Phase 1 Implementation Complete!

The following files have been created for the Share Extension:

- `Hacker News Share Extension/Info.plist` - Extension configuration
- `Hacker News Share Extension/ShareViewController.swift` - Main controller
- `Hacker News Share Extension/ShareExtensionView.swift` - SwiftUI interface
- `Hacker News/Hacker News.entitlements` - Main app entitlements
- `Hacker News Share Extension/Hacker News Share Extension.entitlements` - Extension entitlements

## Required Xcode Setup Steps

### 1. Add Share Extension Target

1. **Open Xcode** and load the Hacker News project
2. **Add New Target**:
   - Click the "+" button in the project navigator or go to File → New → Target
   - Choose "iOS" → "Share Extension"
   - Product Name: `Hacker News Share Extension`
   - Bundle Identifier: `{YOUR_MAIN_APP_BUNDLE_ID}.ShareExtension`
   - Language: Swift
   - Use Core Data: No (we'll use existing persistence)

3. **Delete Default Files**:
   - Delete the auto-generated `ShareViewController.swift`
   - Delete the auto-generated `MainInterface.storyboard`

### 2. Add Created Files to Target

1. **Add our files to the Share Extension target**:
   - Select `Hacker News Share Extension/ShareViewController.swift`
   - Select `Hacker News Share Extension/ShareExtensionView.swift`
   - Select `Hacker News Share Extension/Info.plist`
   - In File Inspector, ensure they're added to "Hacker News Share Extension" target

### 3. Configure App Groups

1. **Main App Configuration**:
   - Select "Hacker News" target
   - Go to "Signing & Capabilities"
   - Add "App Groups" capability
   - Add app group: `group.hackernews.shared`
   - Add the entitlements file: `Hacker News/Hacker News.entitlements`

2. **Share Extension Configuration**:
   - Select "Hacker News Share Extension" target
   - Go to "Signing & Capabilities"  
   - Add "App Groups" capability
   - Add app group: `group.hackernews.shared`
   - Add the entitlements file: `Hacker News Share Extension/Hacker News Share Extension.entitlements`

### 4. Update Info.plist

1. **Replace Extension Info.plist**:
   - Replace the auto-generated Info.plist with our created version
   - Verify `NSExtensionPrincipalClass` points to `$(PRODUCT_MODULE_NAME).ShareViewController`

### 5. Build Settings

1. **Share Extension Build Settings**:
   - iOS Deployment Target: Match main app (probably iOS 15.0+)
   - Swift Language Version: Match main app
   - Code Signing: Use same team as main app

### 6. Test the Extension

1. **Build both targets**:
   ```
   ⌘+B to build
   ```

2. **Run Share Extension**:
   - Select "Hacker News Share Extension" scheme
   - Run on device or simulator
   - Choose an app to test sharing from (Safari, Notes, etc.)
   - Look for "Save to Hacker News" in the share sheet

## Verification Steps

1. ✅ Both main app and extension build without errors
2. ✅ Share extension appears in system share sheet
3. ✅ Extension UI displays correctly with SwiftUI interface
4. ✅ URL extraction works from Safari and other apps
5. ✅ App group entitlements are configured correctly

## Next Steps (Phase 2)

Once Phase 1 is working:
- Implement actual saving functionality
- Add service integrations (Pinboard, LinkDing)
- Enhance UI with animations and better error handling
- Add data synchronization with main app

## Troubleshooting

**Extension doesn't appear in share sheet:**
- Check bundle identifier is correct
- Verify Info.plist activation rules
- Ensure extension is built and installed

**App groups not working:**
- Verify entitlements files are added to targets
- Check app group identifier matches in both targets
- Ensure developer account supports app groups

**Build errors:**
- Check all files are added to correct targets
- Verify Swift version matches between targets
- Clean build folder (⌘+Shift+K) and rebuild