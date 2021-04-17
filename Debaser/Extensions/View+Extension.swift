//
//  View+Extension.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-09.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(
            RoundedCorner(radius: radius, corners: corners)
        )
    }
}
