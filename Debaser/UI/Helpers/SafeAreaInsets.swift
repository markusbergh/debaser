//
//  SafeAreaInsets.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-06-01.
//

import SwiftUI

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(
            where: { $0.isKeyWindow }
        )?.safeAreaInsets ?? .zero).insets
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
