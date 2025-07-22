//
//  ShareExtensionView.swift
//  Hacker News Share Extension
//
//  Created by Claude on 2025/07/22.
//

import SwiftUI

struct ShareExtensionView: View {
    let sharedData: SharedData
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @State private var notes: String = ""
    @State private var selectedDestination: ShareDestination = .readingList
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        Text("Share to Hacker News")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    Divider()
                }
                .padding(.horizontal)
                
                // Content Preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Content")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(sharedData.title)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                        
                        if let url = sharedData.url {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                
                                Text(url.absoluteString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                
                                Spacer()
                            }
                        }
                        
                        if let text = sharedData.text, !text.isEmpty {
                            Text(text)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Destination Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Save to")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(ShareDestination.allCases, id: \.self) { destination in
                            DestinationButton(
                                destination: destination,
                                isSelected: selectedDestination == destination
                            ) {
                                selectedDestination = destination
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notes (Optional)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    TextField("Add notes or tags...", text: $notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(12)
                    
                    Button("Save") {
                        saveContent()
                        onSave()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Share")
            .navigationBarHidden(true)
        }
    }
    
    private func saveContent() {
        // TODO: Implement actual saving logic based on selected destination
        switch selectedDestination {
        case .readingList:
            saveToReadingList()
        case .notes:
            saveToNotes()
        case .pinboard:
            saveToPinboard()
        case .linkding:
            saveToLinkding()
        case .reminders:
            saveToReminders()
        case .mail:
            saveToMail()
        }
    }
    
    // MARK: - Save Methods (Placeholders for now)
    private func saveToReadingList() {
        // Implementation will be added in later phases
    }
    
    private func saveToNotes() {
        // Implementation will be added in later phases
    }
    
    private func saveToPinboard() {
        // Implementation will be added in later phases
    }
    
    private func saveToLinkding() {
        // Implementation will be added in later phases
    }
    
    private func saveToReminders() {
        // Implementation will be added in later phases
    }
    
    private func saveToMail() {
        // Implementation will be added in later phases
    }
}

// MARK: - Supporting Views
struct DestinationButton: View {
    let destination: ShareDestination
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: destination.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(destination.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue : Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Share Destinations
enum ShareDestination: CaseIterable {
    case readingList
    case notes
    case pinboard
    case linkding
    case reminders
    case mail
    
    var title: String {
        switch self {
        case .readingList: return "Reading List"
        case .notes: return "Notes"
        case .pinboard: return "Pinboard"
        case .linkding: return "LinkDing"
        case .reminders: return "Reminders"
        case .mail: return "Mail"
        }
    }
    
    var icon: String {
        switch self {
        case .readingList: return "eyeglasses"
        case .notes: return "note.text"
        case .pinboard: return "pin"
        case .linkding: return "link"
        case .reminders: return "bell"
        case .mail: return "envelope"
        }
    }
}

// MARK: - Preview
struct ShareExtensionView_Previews: PreviewProvider {
    static var previews: some View {
        ShareExtensionView(
            sharedData: SharedData(
                title: "Sample Hacker News Article",
                url: URL(string: "https://example.com"),
                text: "This is a sample article from Hacker News that shows how the share extension will work."
            ),
            onSave: {},
            onCancel: {}
        )
    }
}