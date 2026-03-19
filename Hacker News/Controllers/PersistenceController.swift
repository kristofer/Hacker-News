//
//  PersistenceStorage.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/21.
//

import Foundation
import Combine

/// Persistence Storage Feature
/// Data serialized is saved into userDefaults and read story IDs are synced via iCloud.
class PersistenceController: ObservableObject {
    
    /* Properties
     
        userDefaults        - The local storage method
        settingsKey         - The key for saving settings data
        iCloudReadIdsKey    - The iCloud KV store key for persisting read story IDs
        maxItem             - Maximum items to be saved ( items above this limit will be discated )
        totalItems          - Current number of stories loaded/saved
     
     */
    private let userDefaults: UserDefaults
    private let settingsKey: String = "settings"
    private let iCloudReadIdsKey: String = "readStoryIds"
    /// Maximum items to be saved ( items above this limit will be discated )
    public var maxItems: Int = 500
    // Current number of stories loaded/saved
    private var totalItems: Int = 0
    // In-memory cache for read story IDs sourced from iCloud KV store
    private var cachedReadIds: Set<Int>?
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        // Trigger an initial sync so locally cached data is up to date on launch.
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
}

extension PersistenceController {
    
    /// Save story to local storage.
    /// If a story already exists, it will be discated otherwise overwrite is specified with `true` value.
    /// - Parameters:
    ///   - story: Story model object
    ///   - storySource: Story source enum
    ///   - storyRead: Flag to update the story state ( read/unread )
    ///   - overwrite: Flag to determine if story will be overwritten in case it already exists
    ///
    func saveStory(story: StoryModel, storySource: StorySource, storyRead:Bool, overwrite:Bool = false) {
        
        // Get local story from storage
        let localStory = userDefaults.object(forKey: "\(storySource.rawValue)-\(story.id)")
        // We have to make sure to have something to update
        if (storyRead || overwrite) && localStory == nil { return }
        // We have to make sure if don't find anything, the story read state is false. It means the article is new and it should be saved.
        if !storyRead && localStory != nil { return }        
        // Set read flag
        var story = story
        story.read = storyRead
        // Update userDefaults
        userDefaults.set(try? PropertyListEncoder().encode(story), forKey: "\(storySource.rawValue)-\(story.id)")
        // Apply storage limitation
        if totalItems+1 > maxItems {
            let tmpStories = loadStories(storySource: storySource)
            totalItems = maxItems
            for (index, tmpStory) in tmpStories.enumerated() {
                if index < maxItems {
                    userDefaults.set(try? PropertyListEncoder().encode(tmpStory), forKey: "\(storySource.rawValue)-\(tmpStory.id)")
                } else {
                    userDefaults.removeObject(forKey: "\(storySource.rawValue)-\(tmpStory.id)")
                }
            }
        } else {
            // Increment unreadable stories
            totalItems+=1
        }
    }
    
    /// Update a story read state to true
    /// - Parameters:
    ///   - story: The Story model object
    ///   - storySource: The Story source object
    func readStory(story: StoryModel, storySource: StorySource) {
        // We set overwrite 'true' to update current story on local storage.
        saveStory(story: story, storySource: storySource, storyRead: true, overwrite: true)
        // Persist the story ID to iCloud so other devices know it has been read.
        persistReadStoryId(story.id)
    }
    
    /// Local all stories from local storage and return it
    /// - Parameter storySource: Story source enum
    /// - Returns: Array of Story model in descending date order
    func loadStories(storySource: StorySource) -> [StoryModel] {
        let cloudReadIds = readStoryIds()
        var stories:[StoryModel] = []
        // Iterate throught all saved stories
        for (_, value) in userDefaults.dictionaryRepresentation().filter({$0.key.starts(with: "\(storySource.rawValue)")}) {
            if let data = value as? Data, var story = try? PropertyListDecoder().decode(StoryModel.self, from: data) {
                // Apply iCloud read state: if the story was marked read on any device, honour that here.
                if cloudReadIds.contains(story.id) && story.read != true {
                    story.read = true
                    userDefaults.set(try? PropertyListEncoder().encode(story), forKey: "\(storySource.rawValue)-\(story.id)")
                }
                // Insert new story
                stories.append(story)
            }
        }
        // Set current number of items loaded
        totalItems = stories.count
        // Return sorted by descending date/time
        return stories.sorted(by: { $0.time > $1.time })
    }
    
    /// Save settings to local storage
    /// - Parameter data: Settings model object
    func saveSettings(data:SettingsModel) {
        // Update settings data
        userDefaults.set(try? PropertyListEncoder().encode(data), forKey: settingsKey)
    }
    
    /// Load settings from local storage and return it
    /// - Returns: Settings model object
    func loadSettings() -> SettingsModel {
        if let data = userDefaults.object(forKey: settingsKey) as? Data, let settings = try? PropertyListDecoder().decode(SettingsModel.self, from: data) {
            return settings
        } else {
            // Create and save default settings if nothing is found.
            let defaultSettings = SettingsModel(lastStorySource: .newStories)
            saveSettings(data: defaultSettings)
            return defaultSettings
        }
    }

    // MARK: - iCloud Key-Value Store

    /// Returns the set of story IDs that have been marked as read, persisted in iCloud.
    /// The result is cached in memory to avoid repeated Array → Set conversions.
    func readStoryIds() -> Set<Int> {
        if let cached = cachedReadIds { return cached }
        let array = NSUbiquitousKeyValueStore.default.array(forKey: iCloudReadIdsKey) as? [Int] ?? []
        let ids = Set(array)
        cachedReadIds = ids
        return ids
    }

    /// Adds a story ID to the iCloud key-value store so that it is recognised as read
    /// on all devices signed in to the same iCloud account.
    func persistReadStoryId(_ storyId: Int) {
        var ids = readStoryIds()
        guard !ids.contains(storyId) else { return }
        ids.insert(storyId)
        cachedReadIds = ids
        NSUbiquitousKeyValueStore.default.set(Array(ids), forKey: iCloudReadIdsKey)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    /// Invalidates the in-memory cache of read story IDs.
    /// Should be called when an external iCloud change notification is received
    /// so the next read picks up the latest values from the store.
    func invalidateReadStoryIdsCache() {
        cachedReadIds = nil
    }

}
