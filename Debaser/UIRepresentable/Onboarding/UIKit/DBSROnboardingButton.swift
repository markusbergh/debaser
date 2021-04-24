//
//  DBSROnboardingButton.swift
//  Debaser
//
//  Created by Markus Bergh on 2018-01-25.
//  Copyright © 2018 Markus Bergh. All rights reserved.
//

import UIKit

@IBDesignable class DBSROnboardingButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
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
}
