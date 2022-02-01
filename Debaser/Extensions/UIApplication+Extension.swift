//
//  UIApplication+Extension.swift
//  Debaser
//
//  Created by Markus Bergh on 2022-02-01.
//

import Foundation

extension UIApplication {
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            // Keep only the active scene
            .filter { $0.activationState == .foregroundActive }
            // Only the first `UIWindowScene` is interesting
            .first(where: { $0 is UIWindowScene })
            // Get the associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Keep only the key window
            .first(where: \.isKeyWindow)
    }
}
