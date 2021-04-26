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
    var didFinish: (() -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<WebView>) -> SFSafariViewController {
        let safariView = SFSafariViewController(url: url)
        safariView.delegate = context.coordinator
        
        return safariView
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<WebView>) {}
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: WebView
        
        init(_ view: WebView) {
            parent = view
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            /*
            if SpotifyService.shared.isLoggedIn {
                
            } else {
                print("Not logged in, just cancelled?")
            }
            */
            
            parent.didFinish?()
            
//            if let didFinish = parent.didFinish {
//                didFinish()
//            }
        }
    }
}
