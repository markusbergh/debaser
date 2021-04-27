//
//  OnboardingView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-19.
//

import SwiftUI

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

        return onboardingViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    class Coordinator: NSObject {
        var parent: OnboardingView
        
        init(_ view: OnboardingView) {
            parent = view
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
