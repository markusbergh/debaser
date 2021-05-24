//
//  TabViewRouter.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-10.
//

enum Tab {
    case list
    case favourites
    case settings
    
    enum Identifier: String {
        case list = "TabItemList"
        case favourites = "TabItemFavourites"
        case settings = "TabItemSettings"
    }
}

class TabViewRouter: ObservableObject {
    @Published var currentTab: Tab = .list
}
