# Build Error Fix Instructions

## Problem
You're getting "Multiple commands produce Info.plist" errors because Xcode is trying to process the Info.plist files in two different ways.

## Quick Fix Steps

### Step 1: Clean Build
1. In Xcode, press **⌘+Shift+K** (Product → Clean Build Folder)
2. Close Xcode completely
3. Reopen the project

### Step 2: Fix Build Phases
1. **Select the "Hacker News Share Extension" target**
2. **Go to "Build Phases" tab**
3. **Expand "Copy Bundle Resources" section**
4. **Remove any "Info.plist" files** you see there (they shouldn't be in Copy Bundle Resources)

### Step 3: Verify Info.plist Settings
1. **Select "Hacker News Share Extension" target**
2. **Go to "Build Settings" tab**
3. **Search for "Info.plist"**
4. **Verify "Info.plist File" setting** points to: `Hacker News Share Extension/Info.plist`

### Step 4: Fix File Synchronization Issue
The error suggests Xcode's file system synchronization is including files it shouldn't. Try this:

1. **Right-click on the "Hacker News Share Extension" folder** in Xcode navigator
2. **Select "Remove from Project"**
3. **Choose "Remove References"** (don't delete files)
4. **Right-click in project navigator and "Add Files to Project"**
5. **Select the "Hacker News Share Extension" folder**
6. **Make sure to add it to ONLY the Share Extension target**

### Step 5: Alternative Fix - Manual Configuration
If the above doesn't work, try setting the Info.plist manually:

1. **Select Share Extension target → Build Settings**
2. **Find "Generate Info.plist File"** and set to **NO**
3. **Find "Info.plist File"** and set to: `Hacker News Share Extension/Info.plist`

### Step 6: Build Again
1. **Select "Hacker News" scheme**
2. **Build (⌘+B)**
3. **If successful, test the share extension**

## Expected Result
After these steps:
- Both main app and share extension should build successfully
- No "Multiple commands produce" errors
- Share extension appears in iOS share sheet

## Still Having Issues?

If you're still getting build errors, the issue might be with Xcode's automatic file management. Try these additional steps:

1. **Manually edit the project.pbxproj** (advanced):
   - Look for the "PBXFileSystemSynchronizedBuildFileExceptionSet"
   - Remove "Info.plist" from the membershipExceptions

2. **Or delete and recreate the extension target**:
   - Delete the share extension target
   - Recreate it following the original setup instructions
   - Re-add our custom files

The most likely fix is **Step 2** - removing Info.plist from Copy Bundle Resources where it doesn't belong.