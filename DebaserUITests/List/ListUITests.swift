//
//  ListUITests.swift
//  DebaserUITests
//
//  Created by Markus Bergh on 2021-05-06.
//

import XCTest

class ListUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments = ["-resetUserDefaults", "-skipOnboarding"]
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
        app.terminate()
    }

    func testListDidShow() {
        XCTAssert(app.staticTexts["Today's events"].exists)
        XCTAssert(app.staticTexts["Stockholm"].exists)
        XCTAssert(app.staticTexts["All events"].exists)
    }
    
}

enum MainScreen: String {
    case tabList = "TabItemList"
    case tabFavourites = "TabItemFavourites"
    case tabSettings = "TabItemSettings"
    
    var element: XCUIElement {
        switch self {
        case .tabList, .tabFavourites, .tabSettings:
            return XCUIApplication().buttons.matching(identifier: self.rawValue).element
        }
    }
}
