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

## Development Guidelines

### Code Style
- Follow Swift naming conventions
- Use SwiftUI declarative syntax
- Implement proper error handling with LocalizedError
- Use Combine for reactive programming
- Maintain separation of concerns (MVVM pattern)

### Key Files to Know
- `ContentView.swift:58-71` - Main story grid implementation
- `StoryController.swift:98-138` - Story fetching logic
- `HackerNewsAPI.swift:56-66` - Individual story API call
- `StoryModel.swift:12-24` - Core data model

### Testing
- Unit tests located in `Hacker NewsTests/`
- UI tests in `Hacker NewsUITests/`
- Test data samples in JSON format for offline testing

### Build Configuration
- Xcode project with standard iOS deployment target
- No external dependencies - uses only iOS native frameworks
- App icons and assets configured for multiple resolutions

## Potential Feature Additions

Based on the README notes, the developer has expressed interest in:

1. **Share Extension** - For pinning stories to Pinboard or LinkDing
2. **iCloud Sync** - For story read status across devices
3. **Enhanced iPad Controls** - Additional browser sheet controls
4. **Story Categories** - Beyond just New/Top stories
5. **Search Functionality** - Search within fetched stories
6. **Comments Support** - Display story comments
7. **User Profiles** - View author information
8. **Dark Mode** - Theme support
9. **Favorites/Bookmarks** - Save stories for later
10. **Push Notifications** - For trending stories

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