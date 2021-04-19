//
//  Fonts.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-14.
//

import SwiftUI

enum Fonts: String {
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

struct FontWithLineHeight: ViewModifier {
    let font: UIFont
    let lineHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .font(Font(font))
            .lineSpacing(lineHeight - font.lineHeight)
            .padding(.vertical, (lineHeight - font.lineHeight) / 2)
    }
}

extension View {
    func fontWithLineHeight(font: UIFont, lineHeight: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: FontWithLineHeight(font: font, lineHeight: lineHeight))
    }
}
