//
//  SettingsSpotifyViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-26.
//

import SwiftUI

class SettingsSpotifyViewModel: ObservableObject {
    @Published private(set) var isLoggedIn = false
    
    init() {
        // Subscribe to auth error event
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkSpotifyConnectivity), name: Notification.Name(rawValue: "spotifyAuthError"), object: nil)
        
        // Subscribe to authenticated event
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkSpotifyConnectivity), name: Notification.Name(rawValue: "spotifyUserAuthenticated"), object: nil)
        
        // Subscribe to log out event
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkSpotifyConnectivity), name: Notification.Name(rawValue: "spotifyUserLoggedOut"), object: nil)
        
        // Subscribe to user retrevied event
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCurrentUser), name: Notification.Name(rawValue: "spotifyUserRetrieved"), object: nil)
    }
}

// MARK: Notifications

extension SettingsSpotifyViewModel {
    @objc func checkSpotifyConnectivity() {
        /*
        if (DBSRSpotifyController.shared.isLoggedIn) {
            enableLabel?.text = "Ansluten"
            enableSwitch?.isOn = true
            
            // Dismiss any open modal view
            self.webLoginView?.dismiss(animated: true, completion: nil)
        } else {
            enableLabel?.text = "Ej ansluten"
            enableSwitch?.isOn = false
        }
        */
        
        if SpotifyService.shared.isLoggedIn {
            print("Logged in")
        } else {
            print("Not logged in")
        }
    }
    
    @objc func updateCurrentUser() {
        if !SpotifyService.shared.isLoggedIn {
            // Reset current user
            // currentUserName?.text = ""
            
            return
        }
        
        // Set current user
        if let name: String = SpotifyService.shared.currentUser?.canonicalUserName {
            //currentUserName?.text = String("Användarnamn: ") + name
            print("Current user: \(name)")
        }
    }
}

// MARK: Login

extension SettingsSpotifyViewModel {
    /*
    if UIApplication.shared.canOpenURL(DBSRSpotifyController.shared.loginUrl!) {
        UIApplication.shared.open(DBSRSpotifyController.shared.loginUrl!, options: [:], completionHandler: nil)
    } else {
        guard let auth = DBSRSpotifyController.shared.auth else { return }

        webLoginView = SFSafariViewController(url: auth.spotifyWebAuthenticationURL())
        webLoginView?.dismissButtonStyle = SFSafariViewController.DismissButtonStyle.done
        webLoginView?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        webLoginView?.delegate = self
        
        definesPresentationContext = true
        
        if let webLoginView = webLoginView {
            present(webLoginView, animated: true, completion: nil)
        }

        // Update status bar according to theme
        if let parentController = navigationController as? DBSRNavigationController {
            parentController.darkMode = true

            setNeedsStatusBarAppearanceUpdate()
        }
    }
    */
}
