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
                
        font = Fonts.title.of(size: 49)
        numberOfLines = 0
        lineBreakMode = .byCharWrapping
        
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    convenience init(title: String) {
        self.init()
        
        text = title
        
        configureWithMinimumLinespacing()
    }
    

    private func configureWithMinimumLinespacing(){
        let string = NSMutableAttributedString(string: self.text!)
        let style = NSMutableParagraphStyle()
        let lineHeight = self.font.pointSize - self.font.ascender + self.font.capHeight

        let offset = -lineHeight / 2 * 0.6
        let range = NSMakeRange(0, self.text!.count)
        
        //style.maximumLineHeight = lineHeight
        //style.minimumLineHeight = lineHeight
        style.lineHeightMultiple = 0.6
        style.alignment = self.textAlignment
        
        string.addAttribute(.paragraphStyle, value: style, range: range)
        string.addAttribute(.baselineOffset, value: offset, range: range)

        self.attributedText = string
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
