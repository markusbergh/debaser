//
//  RoundedCorner.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-09.
//

import SwiftUI
import UIKit

struct RoundedCorner: Shape {
    
    // MARK: Public
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}
