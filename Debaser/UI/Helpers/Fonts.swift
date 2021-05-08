//
//  Fonts.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-14.
//

import SwiftUI

enum FontFace: String {
    case title = "DelaGothicOne-Regular"
    
    func of(size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: self.rawValue, size: size) else {
            fatalError("""
                Failed to load the font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        
        return customFont
    }

    func of(size: CGFloat) -> Font {
        return Font.custom(self.rawValue, fixedSize: size)
    }
}

enum FontVariant {
    case large(weight: Font.Weight)
    case body(weight: Font.Weight)
    case small(weight: Font.Weight)
    case smaller(weight: Font.Weight)
    case tiny
    case micro(weight: Font.Weight)
    case mini(weight: Font.Weight)
    
    var font: Font? {
        switch self {
        case .large(let weight):
            return .system(size: 29, weight: weight)
        case .body(let weight):
            return .system(size: 19, weight: weight)
        case .small(let weight):
            return .system(size: 17, weight: weight)
        case .smaller(let weight):
            return .system(size: 16, weight: weight)
        case .tiny:
            return .system(size: 15)
        case .micro(let weight):
            return .system(size: 12, weight: weight)
        case .mini(let weight):
            return .system(size: 11, weight: weight)
        }
    }
}
