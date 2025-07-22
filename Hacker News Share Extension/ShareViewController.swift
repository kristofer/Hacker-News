//
//  ShareViewController.swift
//  Hacker News Share Extension
//
//  Created by Claude on 2025/07/22.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Extract shared content
        extractSharedContent { [weak self] sharedData in
            DispatchQueue.main.async {
                self?.setupSwiftUIView(with: sharedData)
            }
        }
    }
    
    private func setupSwiftUIView(with sharedData: SharedData) {
        let shareExtensionView = ShareExtensionView(
            sharedData: sharedData,
            onSave: { [weak self] in
                self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            },
            onCancel: { [weak self] in
                self?.extensionContext?.cancelRequest(withError: NSError(domain: "ShareExtension", code: 0, userInfo: [NSLocalizedDescriptionKey: "User cancelled"]))
            }
        )
        
        let hostingController = UIHostingController(rootView: shareExtensionView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    private func extractSharedContent(completion: @escaping (SharedData) -> Void) {
        guard let extensionContext = extensionContext,
              let inputItems = extensionContext.inputItems as? [NSExtensionItem] else {
            completion(SharedData(title: "Unknown", url: nil, text: nil))
            return
        }
        
        var sharedData = SharedData(title: "Shared Content", url: nil, text: nil)
        let dispatchGroup = DispatchGroup()
        
        for inputItem in inputItems {
            if let attachments = inputItem.attachments {
                for attachment in attachments {
                    
                    // Handle URLs
                    if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                        dispatchGroup.enter()
                        attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (item, error) in
                            defer { dispatchGroup.leave() }
                            if let url = item as? URL {
                                sharedData.url = url
                                sharedData.title = inputItem.attributedTitle?.string ?? url.host ?? "Shared URL"
                            }
                        }
                    }
                    
                    // Handle text
                    if attachment.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                        dispatchGroup.enter()
                        attachment.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (item, error) in
                            defer { dispatchGroup.leave() }
                            if let text = item as? String {
                                sharedData.text = text
                                if sharedData.title == "Shared Content" {
                                    sharedData.title = String(text.prefix(50))
                                }
                            }
                        }
                    }
                    
                    // Handle web pages
                    if attachment.hasItemConformingToTypeIdentifier(UTType.propertyList.identifier) {
                        dispatchGroup.enter()
                        attachment.loadItem(forTypeIdentifier: UTType.propertyList.identifier, options: nil) { (item, error) in
                            defer { dispatchGroup.leave() }
                            if let dictionary = item as? [String: Any],
                               let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: Any],
                               let urlString = results["URL"] as? String,
                               let url = URL(string: urlString) {
                                sharedData.url = url
                                sharedData.title = results["title"] as? String ?? url.host ?? "Web Page"
                            }
                        }
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(sharedData)
        }
    }
}

// MARK: - SharedData Model
struct SharedData {
    var title: String
    var url: URL?
    var text: String?
}