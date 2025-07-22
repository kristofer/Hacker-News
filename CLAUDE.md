# Hacker News iOS App - Development Guide

## Project Overview

This is a SwiftUI-based iOS application that displays Hacker News stories in a two-column grid layout optimized for iPad. The app fetches stories from the Hacker News API and allows users to browse both "New Stories" and "Top Stories" with an integrated web browser.

## Architecture

### Tech Stack
- **Framework**: SwiftUI (iOS native)
- **Language**: Swift
- **API**: Hacker News Firebase API (https://hacker-news.firebaseio.com/v0)
- **Architecture Pattern**: MVVM with ObservableObjects
- **Data Persistence**: Core Data-like local storage
- **Networking**: Combine framework with URLSession

### Key Components

#### Models
- `StoryModel` - Represents a Hacker News story with id, title, author, score, time, URL, and read status

#### Controllers
- `StoryController` - Main business logic controller managing story fetching, caching, and state
- `PersistenceController` - Handles local storage operations

#### Views
- `ContentView` - Main view with two-column LazyVGrid layout
- `StoryCellView` - Individual story cell component
- `StoryWebView` - Full-screen web browser for reading stories
- `TopBarOptionsView` - Navigation bar controls (sort by score, mark all read)
- `TopBarStorySourceView` - Story source selector (New/Top stories)

#### API
- `HackerNewsAPI` - Handles all API communication using Combine publishers

## Current Features

- Two-column grid layout optimized for iPad
- Toggle between "New Stories" and "Top Stories"
- Sort stories by score or date
- Mark stories as read (visual opacity change)
- Mark all stories as read
- Pull-to-refresh functionality
- Offline support with local storage
- Full-screen web browser with swipe-back navigation
- Automatic refresh when app returns to foreground
- **Scroll to top button** with refresh functionality in navigation bar
- **Share functionality** in StoryWebView with iOS native share sheet
- **Share Extension** for saving URLs from other apps (Phase 1 complete)

## Development Guidelines

### Code Style
- Follow Swift naming conventions
- Use SwiftUI declarative syntax
- Implement proper error handling with LocalizedError
- Use Combine for reactive programming
- Maintain separation of concerns (MVVM pattern)

### Key Files to Know
- `ContentView.swift:58-71` - Main story grid implementation
- `ContentView.swift:173-180` - Navigation bar with scroll to top button
- `StoryController.swift:98-138` - Story fetching logic
- `HackerNewsAPI.swift:56-66` - Individual story API call
- `StoryModel.swift:12-24` - Core data model
- `StoryWebView.swift:72-80` - Share button implementation
- `StoryWebView.swift:119-165` - ShareSheet UIViewControllerRepresentable
- `Hacker News Share Extension/` - Complete share extension implementation

### Testing
- Unit tests located in `Hacker NewsTests/`
- UI tests in `Hacker NewsUITests/`
- Test data samples in JSON format for offline testing

### Build Configuration
- Xcode project with standard iOS deployment target
- No external dependencies - uses only iOS native frameworks
- App icons and assets configured for multiple resolutions

## Recent Implementations

### Scroll to Top Button (Completed)
**Location**: `ContentView.swift:173-180`

Added a scroll to top button in the navigation bar that provides dual functionality:
- **Refresh Stories**: Calls `storyController.retrieveNewStories()` for current category
- **Scroll to Top**: Smooth animated scroll using `ScrollViewReader` and `scrollProxy.scrollTo()`
- **Visual Design**: Blue circular button with up arrow, positioned left of story source chooser
- **Auto-scroll**: Also triggers when switching between New/Top Stories categories

**Key Features**:
- Uses `NotificationCenter` for clean communication between nav bar and scroll view
- 0.5-second `easeInOut` animation for smooth scrolling
- Resets `topScore` filter when refreshing to show latest stories first

### Share Functionality (Completed)
**Location**: `StoryWebView.swift:72-80` and `StoryWebView.swift:119-165`

Implemented native iOS sharing in the story web view with comprehensive error handling:

**Share Button**:
- Added to StoryWebView's yellow top bar between close and Safari buttons
- Uses `square.and.arrow.up` system icon (standard iOS share icon)
- Sized at 20x25 points with indigo color matching other buttons

**ShareSheet Implementation**:
- `UIViewControllerRepresentable` wrapper for `UIActivityViewController`
- Shares both story URL and title for rich content sharing
- iPad-specific popover configuration to prevent crashes
- Enhanced debug logging for troubleshooting device issues
- Graceful error handling with completion handler

**Supported Share Destinations**:
- All system apps (Mail, Messages, Notes, Reminders, etc.)
- Social media apps (Twitter, Facebook, etc.)
- Third-party apps that accept URLs
- Copy to clipboard functionality
- Reading List integration
- Your custom Share Extension (when implemented)

**iPad Considerations**:
- Proper popover presentation controller setup
- Source rect configuration for popover positioning
- Fallback positioning for center-screen presentation

### Share Extension (Phase 1 Complete)
**Location**: `Hacker News Share Extension/` directory

Implemented a complete Share Extension that appears in iOS share sheets:

**Core Components**:
- `ShareViewController.swift` - Main extension controller with URL extraction
- `ShareExtensionView.swift` - SwiftUI interface with destination picker
- `Info.plist` - Extension configuration for URL and text content
- App group entitlements for data sharing between main app and extension

**Features Implemented**:
- URL extraction from various content types (direct URLs, web pages, text)
- Modern SwiftUI interface with story preview
- Multiple destination options (Pinboard, LinkDing, Reading List, etc.)
- Content preview showing extracted title and URL
- Optional notes/tags input field
- Proper error handling and user feedback

**Technical Implementation**:
- Uses `NSItemProvider` for content extraction from share data
- `UIHostingController` bridge for SwiftUI in UIKit extension
- App Groups (`group.hackernews.shared`) for data sharing
- Proper bundle configuration and extension activation rules

## Share Extension Implementation Plan

### Overview
Implement a Share Extension that allows users to share Hacker News story URLs to external apps like Pinboard, LinkDing, Safari Reading List, Notes, and other URL/PDF-compatible applications.

### Implementation Steps

#### Phase 1: Basic Share Extension Setup
1. **Create Share Extension Target**
   - Add new Share Extension target to Xcode project
   - Configure `Info.plist` to accept URLs and text content
   - Set up proper bundle identifier and app group

2. **Configure Extension Properties**
   ```xml
   <key>NSExtensionActivationRule</key>
   <dict>
       <key>NSExtensionActivationSupportsText</key>
       <true/>
       <key>NSExtensionActivationSupportsWebURLWithMaxCount</key>
       <integer>1</integer>
   </dict>
   ```

3. **SwiftUI Integration**
   - Replace default `SLComposeServiceViewController` with `UIViewController`
   - Implement `UIHostingController` to bridge UIKit to SwiftUI
   - Create custom SwiftUI share interface

#### Phase 2: Core Extension Implementation
1. **ShareViewController.swift**
   ```swift
   class ShareViewController: UIViewController {
       override func viewDidLoad() {
           super.viewDidLoad()
           let shareView = ShareExtensionView()
           let hostingController = UIHostingController(rootView: shareView)
           addChild(hostingController)
           view.addSubview(hostingController.view)
       }
   }
   ```

2. **URL Extraction Logic**
   - Parse incoming share data using `NSItemProvider`
   - Extract URLs from various content types
   - Handle both direct URLs and text containing URLs
   - Extract story metadata (title, source) when available

3. **Data Models**
   - Create `SharedStoryModel` for extension use
   - Implement app group container for data sharing
   - Add Core Data or SwiftData models for saved shares

#### Phase 3: UI Implementation
1. **ShareExtensionView.swift**
   - SwiftUI view with story preview
   - Action buttons for different sharing options
   - Preview of extracted URL and metadata
   - Custom sharing destinations

2. **Key UI Components**
   - Story title and URL display
   - Quick action buttons (Save to Pinboard, LinkDing, etc.)
   - Custom note/tag input field
   - Share to system apps (Reading List, Notes, etc.)

#### Phase 4: Integration with Main App
1. **App Group Configuration**
   - Set up shared app group identifier
   - Configure data sharing between main app and extension
   - Implement shared storage for extension preferences

2. **Data Synchronization**
   - Share extension preferences with main app
   - Synchronize saved/shared stories
   - Update main app's read status when stories are shared

#### Phase 5: External Service Integration
1. **Pinboard Integration**
   - API authentication setup
   - URL posting with tags and descriptions
   - Error handling and retry logic

2. **LinkDing Support**
   - Self-hosted bookmark service integration
   - Custom URL scheme support
   - Bulk tagging capabilities

3. **System Integration**
   - Safari Reading List integration
   - Notes app integration
   - Reminders app integration
   - Mail app integration

### Technical Considerations

#### File Structure
```
Hacker News Share Extension/
├── ShareViewController.swift
├── ShareExtensionView.swift
├── Models/
│   ├── SharedStoryModel.swift
│   └── ShareDestination.swift
├── Services/
│   ├── PinboardService.swift
│   ├── LinkDingService.swift
│   └── URLExtractionService.swift
└── Resources/
    ├── Info.plist
    └── Assets.xcassets
```

#### Key Implementation Details
1. **URL Detection**
   ```swift
   itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (item, error) in
       if let url = item as? URL {
           // Process URL
       }
   }
   ```

2. **App Group Sharing**
   ```swift
   let containerURL = FileManager.default.containerURL(
       forSecurityApplicationGroupIdentifier: "group.com.yourapp.hackernews"
   )
   ```

3. **SwiftUI Bridge**
   - Use `UIHostingController` to embed SwiftUI in UIKit extension
   - Handle navigation and dismissal properly
   - Manage extension lifecycle

#### Challenges & Solutions
1. **No SwiftUI Previews**: Test UI in main app or use simulator
2. **Limited Debugging**: Use extensive logging and proper error handling
3. **Memory Constraints**: Optimize for minimal memory usage
4. **API Rate Limits**: Implement proper queuing and retry mechanisms

### Testing Strategy
1. **Unit Tests**: URL extraction, data parsing, service integrations
2. **Integration Tests**: App group sharing, data synchronization
3. **Manual Testing**: Various content types, different apps, error scenarios
4. **Performance Testing**: Memory usage, response time, battery impact

### Future Enhancements
- Support for sharing multiple stories at once
- Custom sharing workflows
- Integration with more bookmark services
- Sharing analytics and usage tracking
- Offline sharing queue with sync when online

## Potential Feature Additions

Based on the README notes and recent implementations:

### ✅ Recently Completed Features
1. **Scroll to Top Button** - ✅ **COMPLETED** - Navigation bar refresh and scroll functionality
2. **Share Functionality** - ✅ **COMPLETED** - Native iOS sharing from StoryWebView
3. **Share Extension (Phase 1)** - ✅ **COMPLETED** - Basic extension for saving URLs from other apps

### 🚧 In Progress / Next Phase
4. **Share Extension (Phase 2+)** - Service integrations (Pinboard, LinkDing, system apps)

### 📋 Planned Features
5. **iCloud Sync** - For story read status across devices
6. **Enhanced iPad Controls** - Additional browser sheet controls
7. **Story Categories** - Beyond just New/Top stories
8. **Search Functionality** - Search within fetched stories
9. **Comments Support** - Display story comments
10. **User Profiles** - View author information
11. **Dark Mode** - Theme support
12. **Favorites/Bookmarks** - Save stories for later
13. **Push Notifications** - For trending stories
14. **Offline Reading Queue** - Download stories for offline access

## API Limitations

- Maximum 110 stories fetched per request (configurable in `HackerNewsAPI.swift:18`)
- API rate limiting considerations
- Network error handling with offline fallback

## Local Storage

Stories are cached locally to support:
- Offline reading
- Read status persistence
- Faster app launches
- Network failure recovery

## UI/UX Notes

- Yellow background with rounded corners for story cells
- Opacity change (0.4) for read stories
- Navigation bar integration with iOS design patterns
- Full-screen web view with dismiss animation
- Pull-to-refresh gesture support
- **Scroll to top button** positioned left of story source chooser
- **Share button** in StoryWebView top bar with standard iOS share icon
- **Share Extension UI** with modern SwiftUI design and destination picker

## Troubleshooting

### Scroll to Top Button Issues
- **Button not working**: Check NotificationCenter implementation in ContentView.swift:35-38
- **Scroll animation jumpy**: Ensure LazyVStack has proper "top" id anchor
- **Button positioning**: Verify HStack layout in navigation bar trailing area

### Share Functionality Issues
- **Share sheet not appearing**: Check iPad popover configuration in ShareSheet
- **Sandbox extension errors**: Normal in simulator, test on physical device
- **URL not sharing properly**: Verify story.url is valid URL string
- **Debug sharing issues**: Check Xcode console for 📤 and 🚫 log messages

### Share Extension Issues
- **Extension not in share sheet**: Verify extension target is built and installed
- **Build errors**: Check Info.plist is not in Copy Bundle Resources phase
- **App groups not working**: Verify entitlements are added to both targets
- **URL extraction fails**: Check NSItemProvider implementation for different content types

### iPad-Specific Issues
- **Share popover crashes**: Ensure popoverPresentationController.sourceView is set
- **Extension UI layout**: Test in both portrait and landscape orientations
- **Performance on older iPads**: Consider reducing animation complexity if needed