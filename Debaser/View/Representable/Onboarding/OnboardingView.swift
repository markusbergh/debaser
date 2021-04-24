//
//  OnboardingView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-19.
//

import SwiftUI

struct OnboardingView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        
        guard let onboardingViewController = storyboard.instantiateInitialViewController() else {
            return UIViewController()
        }
        
        return onboardingViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    class Coordinator: NSObject {
        var parent: OnboardingView
        
        init(_ view: OnboardingView) {
            parent = view
        }
    }
}
