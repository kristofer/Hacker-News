//
//  StoryCellView.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/24.
//

import SwiftUI

/// A View to display a Story.
///
/// StoryModel object is used to get story details for the view
struct StoryCellView: View {

    /// The Story to be displayed in this view
    @Binding var story:StoryModel

    @StateObject private var imageLoader = StoryImageLoader()

    /// In compact width (iPhone portrait, iPad slide-over/split view) cells
    /// are too narrow for a title-left / image-right row; the title gets
    /// squeezed. In that case we stack the image centered at the top and put
    /// the title below it instead.
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Custom Date/Time formatter to return a relative
    // time from current date, ie: "1 day ago"
    private let timePass: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    var body: some View {
        VStack(alignment:.leading, spacing: 3) {
            if horizontalSizeClass == .compact {
                if let imageURL = imageLoader.imageURL {
                    HStack {
                        Spacer()
                        storyImage(url: imageURL, size: 80)
                        Spacer()
                    }
                }
                titleText
            } else {
                HStack(alignment: .top, spacing: 8) {
                    titleText
                    if let imageURL = imageLoader.imageURL {
                        storyImage(url: imageURL, size: 60)
                    }
                }
            }

            if let url = URL(string: story.url)?.host {
                Text("\(url)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            HStack {
                Text("\(timePass.localizedString(for: Date(timeIntervalSince1970: story.time), relativeTo: Date()))")
                    .font(.caption)
                    .fontWeight(.light)
                    .padding(.top, 15)
                Spacer()
                Text("\(Image(systemName: "bolt"))\(story.score)")
                    .font(.caption)
            }
            .opacity(0.8)
        }
        .foregroundColor(story.read ?? false ? .gray : .primary)
        .onAppear {
            imageLoader.load(for: story.url)
        }
    }

    private var titleText: some View {
        Text(story.title)
            .font(.headline)
            .fontWeight(.heavy)
            .foregroundColor(.indigo)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func storyImage(url: URL, size: CGFloat) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            default:
                EmptyView()
            }
        }
    }
}

struct StoryCellView_Previews: PreviewProvider {
    static var previews: some View {
        StoryCellView(story: .constant(StoryModel(id: 0, title: "Test Title", by: "ClawsOnPaws", time: 1632301218, score: 100, url: "https://arstechnica.com/science/2021/09/braille-display-demo-refreshes-with-miniature-fireballs/")))
            .previewLayout(.sizeThatFits)
    }
}
