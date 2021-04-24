//
//  DBSROnboardingView.swift
//  Debaser
//
//  Created by Markus Bergh on 2018-01-25.
//  Copyright © 2018 Markus Bergh. All rights reserved.
//

import UIKit

@IBDesignable class DBSROnboardingView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
                
        setShadow()
        updateCornerRadius()
    }
    
    @IBInspectable var rounded: CGFloat = 0.0 {
        didSet {
            updateCornerRadius()
        }
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = rounded
    }
    
    func setShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 15
    }
}
