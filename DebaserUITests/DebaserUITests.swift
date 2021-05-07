//
//  DebaserUITests.swift
//  DebaserUITests
//
//  Created by Markus Bergh on 2021-05-06.
//

import XCTest

class DebaserUITests: XCTestCase {
    
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

    func testList() {
        XCTAssert(app.staticTexts["Today's concerts"].exists)
        XCTAssert(app.staticTexts["Stockholm"].exists)
        XCTAssert(app.staticTexts["All concerts"].exists)
    }
    
    func testSettings() {
        let tab = MainScreen.tabSettings.element
        XCTAssert(tab.exists)
        tab.tap()
        
        XCTAssert(app.staticTexts["Settings"].waitForExistence(timeout: 10))

        XCTAssert(SettingsScreen.toggleThemeSystem.element.waitForExistence(timeout: 10))
        
        expectation(for: NSPredicate(format: "hittable == 1"), evaluatedWith: SettingsScreen.toggleThemeSystem.element, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        // Disable system theme should reveal user theme toggle
        SettingsScreen.toggleThemeSystem.element.tap()
        sleep(2)
        XCTAssert(SettingsScreen.toggleThemeUser.element.waitForExistence(timeout: 10))
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

enum SettingsScreen: String {
    case toggleThemeSystem = "ToggleSystemTheme"
    case toggleThemeUser = "ToggleUserTheme"
    
    var element: XCUIElement {
        switch self {
        case .toggleThemeSystem, .toggleThemeUser:
            return XCUIApplication().switches.matching(identifier: self.rawValue).element
        }
    }
}

extension XCUIElement {
    func tapUnhittable() {
        XCTContext.runActivity(named: "Tap \(self) by coordinate") { _ in
            coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0)).tap()
        }
    }
}
