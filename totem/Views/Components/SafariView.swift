//
//  SafariView.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        configuration.barCollapsingEnabled = true

        let safari = SFSafariViewController(url: url, configuration: configuration)
        return safari
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - View Modifier for presenting Safari
extension View {
    func safariSheet(url: Binding<URL?>) -> some View {
        self.sheet(item: url) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
    }
}

// Make URL conform to Identifiable for sheet presentation
extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
