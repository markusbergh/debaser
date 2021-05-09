//
//  TitleLabel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-19.
//

import UIKit

class TitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: .zero)
                
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    convenience init(title: String, fontSize: CGFloat, lineLimit: Int, textColor: UIColor) {
        self.init()

        text = title
        font = UIFont.Family.title.of(size: fontSize)
        numberOfLines = lineLimit
        self.textColor = textColor

        configureWithMinimumLinespacing()
    }
    

    private func configureWithMinimumLinespacing(){
        let string = NSMutableAttributedString(string: self.text!)
        let style = NSMutableParagraphStyle()
        let lineHeight = self.font.pointSize - self.font.ascender + self.font.capHeight

        let offset = -(lineHeight / 2) * -0.1
        let range = NSMakeRange(0, self.text!.count)
        
        style.lineHeightMultiple = 0.8
        style.alignment = self.textAlignment
        style.lineBreakMode = .byWordWrapping
        
        string.addAttribute(.paragraphStyle, value: style, range: range)
        string.addAttribute(.baselineOffset, value: offset, range: range)

        attributedText = string
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
