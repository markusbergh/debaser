//
//  UIDevice+Extension.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-20.
//

import UIKit

extension UIDevice {
    
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    
    var iPhone5: Bool {
        return UIScreen.main.nativeBounds.height == 1336
    }
        
    enum ScreenType: String {
        case iPhone4 = "iPhone 4, iPhone 4s"
        case iPhone5 = "iPhone 5, iPhone 5s"
        case iPhone6 = "iphone 6"
        case unknown
    }
    
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4
        case 1334:
            return .iPhone6
        case 1136:
            return .iPhone5
        default:
            return .unknown
        }
    }
}
