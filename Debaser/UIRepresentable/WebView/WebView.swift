//
//  WebView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import SafariServices
import SwiftUI

struct WebView: UIViewControllerRepresentable {
    var url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<WebView>) -> SFSafariViewController {
        let safariView = SFSafariViewController(url: url)
        
        return safariView
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<WebView>) {}
}
