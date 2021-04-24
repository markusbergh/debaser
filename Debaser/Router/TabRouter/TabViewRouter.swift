//
//  TabViewRouter.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-10.
//

import SwiftUI

enum Tab {
    case list
    case favourites
    case settings
}

class TabViewRouter: ObservableObject {
    @Published var currentTab: Tab = .list
    
    init() {
        print("init tabViewRoute")
    }
}
