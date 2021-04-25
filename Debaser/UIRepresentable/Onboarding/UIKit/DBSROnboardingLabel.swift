//
//  DBSROnboardingLabel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-25.
//

import UIKit

class DBSROnboardingLabel: UILabel {
    @IBInspectable var localisedKey: String? {
        didSet {
            guard let key = localisedKey else { return }
            text = NSLocalizedString(key, comment: "")
        }
    }
}
