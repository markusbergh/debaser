//
//  OnboardingView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-19.
//

import SwiftUI

protocol OnboardingViewDelegate: AnyObject {
    func showSpotifySettings()
}

struct OnboardingView: UIViewControllerRepresentable {
    @EnvironmentObject var store: AppStore

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)

        guard let onboardingViewController = storyboard.instantiateInitialViewController() as? DBSROnboardingViewController else {
            return UIViewController()
        }

        // Set dark mode according to store
        onboardingViewController.usesDarkMode = store.state.settings.darkMode.value
        
        // View delegate
        onboardingViewController.onboardingViewDelegate = context.coordinator

        return onboardingViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    class Coordinator: NSObject, OnboardingViewDelegate {
        var parent: OnboardingView
        
        init(_ view: OnboardingView) {
            parent = view
        }
        
        func showSpotifySettings() {
            let store = parent.store
            
            store.dispatch(action: .settings(.pushToSpotifySettings))
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
