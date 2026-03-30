//
//  StoryImageLoader.swift
//  Hacker News
//
//  Fetches Open Graph preview images from story URLs.
//

import SwiftUI

@MainActor
class StoryImageLoader: ObservableObject {
    @Published var imageURL: URL?

    private static var cache = NSCache<NSString, NSURL>()
    private static var failedURLs = Set<String>()

    func load(for storyURL: String) {
        let cacheKey = storyURL as NSString

        if let cached = Self.cache.object(forKey: cacheKey) {
            imageURL = cached as URL
            return
        }

        if Self.failedURLs.contains(storyURL) { return }

        guard let url = URL(string: storyURL) else {
            Self.failedURLs.insert(storyURL)
            return
        }

        Task {
            var request = URLRequest(url: url)
            request.timeoutInterval = 8

            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                // Only look at the first portion of HTML for the og:image tag
                let limit = min(data.count, 50_000)
                let head = String(data: data[0..<limit], encoding: .utf8) ?? ""

                if let ogURL = Self.extractOGImage(from: head) {
                    Self.cache.setObject(ogURL as NSURL, forKey: cacheKey)
                    imageURL = ogURL
                } else {
                    Self.failedURLs.insert(storyURL)
                }
            } catch {
                Self.failedURLs.insert(storyURL)
            }
        }
    }

    private static func extractOGImage(from html: String) -> URL? {
        // Match <meta property="og:image" content="..."> in either attribute order
        let patterns = [
            #"<meta[^>]*property=["']og:image["'][^>]*content=["']([^"']+)["']"#,
            #"<meta[^>]*content=["']([^"']+)["'][^>]*property=["']og:image["']"#
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                  let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
                  let range = Range(match.range(at: 1), in: html) else { continue }

            let urlString = String(html[range])
            if let url = URL(string: urlString), url.scheme == "https" || url.scheme == "http" {
                return url
            }
        }
        return nil
    }
}
