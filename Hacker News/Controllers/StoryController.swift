//
//  StoryFetcher.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/22.
//

import Foundation
import Combine
import SwiftUI

/// Story Source Enum defines constants that can be used to specify
/// the story souce chosen within the app.
///
///    `newStories` - Will return the new stories title string
///
///    `topStories` - Will return the top stories title string
///
///    `func endPointConversion`  - Bridges the Hacker **HackerNewsAPI.EndPoint** returning its source URL
///
public enum StorySource: String, CaseIterable, Codable {
    
    case newStories = "New Stories"
    case topStories = "Top Stories"
    
    // Convinient bridge from API endpoints
    func endPointConvesion() -> HackerNewsAPI.EndPoint {
        switch self {
            case .newStories: return .newStories
            case .topStories: return .topStories
        }
    }
}

/**
 StoryControllerProtocol provides the interface that is
 intended for use by `StoryController` class.
 */
protocol StoryControllerProtocol  {
    
    /* Properties
     
     stories         - Receives retrieved stories from API.
     unreadStories   - Holds the current unread stories for selected story source.
     fetchError      - Will be set when errors occurs while retrieving stories from API.
     
     */
    var stories: [StoryModel] { get set }
    var unreadStories: Int { get set }
    var fetchError: HackerNewsAPI.APIFailureCondition? { get set }
    
    /* Methods
     
     retrieveNewStories     - Retrieve stories from API based on story source set and save to storage.
     loadMoreStories        - Load the next page of stories from the API.
     loadLocalStories       - Load stories from storage based on story source set.
     readStory              - Will be set when errors occurs while retrieving stories from API.
     sortByScore            - Holds the selected story source. Affects when retrieving stories from API.
     
     */
    func retrieveNewStories(from storySource: StorySource)
    func loadMoreStories(from storySource: StorySource)
    func loadLocalStories(from storySource: StorySource)
    func readStory(story: StoryModel)
    func readAllStories(from storySource: StorySource)
    func sortByScore(_ topScore:Bool)
    
    var isLoadingMore: Bool { get }
    var hasMoreStories: Bool { get }
    
}

/// This class combines ( wrapper ) the Hacker News API and Persistence storage methods
/// to manage all data and key observers.
class StoryController: StoryControllerProtocol, ObservableObject {
    
    /* Protocol properties

        stories         - Receives retrieved stories from API.
        unreadStories   - Holds the current unread stories for selected story source.
        fetchError      - Will be set when errors occurs while retrieving stories from API.

    */
    @Published var stories: [StoryModel] = []
    @Published var unreadStories: Int = 0
    @Published var fetchError: HackerNewsAPI.APIFailureCondition? = nil
    
    /* Class properties

        cancellable     - A type-erasing cancellable object used when retrieving stories.
        api             - The Hacker News API instance.
        localStorage    - The Persistence storage instance.
        isLoadingMore   - True while a page of stories is being fetched.
        hasMoreStories  - True when additional pages of stories are available.
        allStoryIds     - Full ordered list of story IDs from the current API response.
        currentPage     - Index of the next page to fetch (0-based).
        pageSize        - Number of stories fetched per page.

     */
    var cancellable = Set<AnyCancellable>()
    let api = HackerNewsAPI()
    let localStorage = PersistenceController()
    @Published var isLoadingMore: Bool = false
    @Published var hasMoreStories: Bool = false
    private var allStoryIds: [Int] = []
    private var currentPage: Int = 0
    let pageSize: Int = 30

    init() {
        // Observe iCloud key-value store changes so that read state updated on another
        // device is immediately reflected in the current session.
        NotificationCenter.default.publisher(
            for: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.applyiCloudReadState()
        }
        .store(in: &cancellable)
    }

    
    /// Fetch for new stories from selected source and update the `stories` property and
    /// save new stories locally.
    /// - Parameter storySource: Enum that controls the story souce for Hacker News articles
    func retrieveNewStories(from storySource: StorySource) {

        // Reset pagination state
        allStoryIds = []
        currentPage = 0
        hasMoreStories = false
        isLoadingMore = false

        // Fetch news stories ID from API
        api.allStoriesId(endPoint: storySource.endPointConvesion().url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                    case .failure(_):
                        self?.fetchError = .invalidServerResponse
                    case .finished:
                        self?.fetchError = nil
                }
            } receiveValue: { [weak self] newIds in
                guard let self = self else { return }
                self.allStoryIds = newIds
                self.hasMoreStories = !newIds.isEmpty
                self.fetchNextPage(from: storySource)
            }
            .store(in: &cancellable)

    }

    /// Load the next page of stories from the API for the given source.
    /// Does nothing if a fetch is already in progress (`isLoadingMore == true`)
    /// or there are no additional stories available (`hasMoreStories == false`).
    /// - Parameter storySource: Enum that controls the story source for Hacker News articles
    func loadMoreStories(from storySource: StorySource) {
        guard !isLoadingMore && hasMoreStories else { return }
        fetchNextPage(from: storySource)
    }

    /// Fetch a single page of stories starting at `currentPage * pageSize`.
    /// Saves all fetched stories at once and updates the UI with a single `loadLocalStories` call.
    private func fetchNextPage(from storySource: StorySource) {
        let start = currentPage * pageSize
        guard start < allStoryIds.count else {
            hasMoreStories = false
            isLoadingMore = false
            return
        }
        let end = min(start + pageSize, allStoryIds.count)
        let pageIds = Array(allStoryIds[start..<end])
        currentPage += 1
        isLoadingMore = true
        hasMoreStories = end < allStoryIds.count

        // Create one publisher per story ID, merge them, and collect all results
        // before writing to storage. This avoids repeated UI updates and is safe
        // because each story publisher delivers on the main thread.
        let publishers = pageIds.map { id in
            self.api.story(endPoint: HackerNewsAPI.EndPoint.story(id).url)
        }

        Publishers.MergeMany(publishers)
            .collect()
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingMore = false
                if case .failure = completion {
                    self.fetchError = .invalidServerResponse
                }
            } receiveValue: { [weak self] stories in
                guard let self = self else { return }
                // Save every story in the page, then refresh the UI once.
                for story in stories {
                    var mutableStory = story
                    mutableStory.read = false
                    self.localStorage.saveStory(story: mutableStory, storySource: storySource, storyRead: false)
                }
                self.loadLocalStories(from: storySource)
            }
            .store(in: &self.cancellable)
    }
    
    /// Load stories from local storage and set `stories` and `unreadStories` property
    func loadLocalStories(from storySource: StorySource) {
        withAnimation {
            // Set `stories` property with local storage data
            stories = localStorage.loadStories(storySource: storySource)
        }
        // Set unread stories
        unreadStories = stories.filter { $0.read == false }.count
    }
    
    /// Set a story to read state
    /// - Parameter story: Story model
    func readStory(story: StoryModel) {
        guard story.read == false else { return }
        // Iterate throught all story sources to update the story read state
        // because they may share the same story, ie: New Stories & Top Stories.
        // It's save because readStory method updates based on the Story ID.
        for source in StorySource.allCases {
            localStorage.readStory(story: story, storySource: source)
        }
        // Update `stories` and `unreadStories` property for current story source articles.
        if let index = stories.firstIndex(where: {$0.id == story.id}) {
            withAnimation {
                stories[index].read = true
                unreadStories-=1
            }
        }
    }
    
    /// Set all story in `stories` parameter to read state
    func readAllStories(from storySource: StorySource) {
        for story in stories {
            readStory(story: story)
        }
        unreadStories = 0
    }
    
    /// Sort in place stories order between scores and date/time
    /// `true` will sort by score and `false` by date/time (default)
    /// - Parameter topScore: Boolean
    func sortByScore(_ topScore:Bool) {
        withAnimation {
            stories.sort(by: topScore ? { $0.score > $1.score } : { $0.time > $1.time })
        }
    }

    /// Applies the latest iCloud read state to the currently displayed stories.
    /// Called when the iCloud key-value store notifies us of external changes.
    private func applyiCloudReadState() {
        // Invalidate the cached set so we pick up the updated values from iCloud.
        localStorage.invalidateReadStoryIdsCache()
        let readIds = localStorage.readStoryIds()
        var changed = false
        for index in stories.indices {
            if stories[index].read != true && readIds.contains(stories[index].id) {
                stories[index].read = true
                changed = true
            }
        }
        if changed {
            withAnimation {
                unreadStories = stories.filter { $0.read == false }.count
            }
        }
    }
    
}
