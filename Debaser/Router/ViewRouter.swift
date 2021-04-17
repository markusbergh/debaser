//
//  ViewRouter.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-10.
//

import SwiftUI

enum Page {
    case list
    case favourites
    case news
    case settings
}

class ViewRouter: ObservableObject {
    @Published var currentPage: Page = .list
}
