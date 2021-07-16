//
//  SettingsUITests.swift
//  DebaserUITests
//
//  Created by Markus Bergh on 2021-07-15.
//

import XCTest

class SettingsUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments = ["-resetUserDefaults", "-skipOnboarding"]
        app.launch()
        
        let tab = MainScreen.tabSettings.element
        XCTAssert(tab.exists)
        tab.tap()
    }

    override func tearDown() {
        super.tearDown()
        app.terminate()
    }
    
    func testSettingsUserCanOverrideTheme() throws {
        XCTAssert(app.staticTexts["Settings"].waitForExistence(timeout: 10))

        XCTAssert(SettingsScreen.toggleThemeSystem.element.waitForExistence(timeout: 10))
        XCTAssert(SettingsScreen.toggleThemeSystem.element.isHittable)
        
        SettingsScreen.toggleThemeSystem.element.tap(withNumberOfTaps: 1, numberOfTouches: 2)

        // Disable system theme should reveal user theme toggle
        XCTAssert(SettingsScreen.toggleThemeUser.element.waitForExistence(timeout: 10))
        XCTAssert(SettingsScreen.toggleThemeUser.element.isHittable)
    }
    
    func testSettingsUserCanOpenOnboarding() throws {
        XCTAssert(app.staticTexts["Settings"].waitForExistence(timeout: 10))

        XCTAssert(SettingsScreen.buttonOnboarding.element.exists)
        SettingsScreen.buttonOnboarding.element.tap()
        
        XCTAssert(OnboardingScreen.onboardingStep1Title.element.waitForExistence(timeout: 10.0))
    }
}

enum SettingsScreen: String {
    case toggleThemeSystem = "ToggleSystemTheme"
    case toggleThemeUser = "ToggleUserTheme"
    case buttonOnboarding = "Show onboarding"
    
    var element: XCUIElement {
        switch self {
        case .toggleThemeSystem, .toggleThemeUser:
            return XCUIApplication().switches.matching(identifier: self.rawValue).element
        case .buttonOnboarding:
            return XCUIApplication().buttons[self.rawValue]
        }
    }
}
