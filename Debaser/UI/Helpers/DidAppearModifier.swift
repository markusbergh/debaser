//
//  DidAppearModifier.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-09.
//

import UIKit
import SwiftUI

struct DidAppearHandler: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    let onDidAppear: () -> Void
    
    class Coordinator: UIViewController {
        let onDidAppear: () -> Void

        init(onDidAppear: @escaping () -> Void) {
            self.onDidAppear = onDidAppear
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            onDidAppear()
        }
    }

    func makeCoordinator() -> DidAppearHandler.Coordinator {
        Coordinator(onDidAppear: onDidAppear)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DidAppearHandler>) -> UIViewController {
        context.coordinator
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DidAppearHandler>) {}
}

struct DidAppearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content
            .background(DidAppearHandler(onDidAppear: callback))
    }
}

extension View {
    func onDidAppear(_ perform: @escaping () -> Void) -> some View {
        self.modifier(DidAppearModifier(callback: perform))
    }
}

