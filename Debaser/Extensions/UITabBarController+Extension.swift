//
//  UITabBarController+Extension.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-08.
//

import UIKit

extension UITabBarController {
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let appearance = UITabBarAppearance()
        
        appearance.backgroundColor = UIColor.tabBarBackground
        appearance.shadowColor = UIColor.tabBarBorder
        
        tabBar.standardAppearance = appearance
    }
    
}
