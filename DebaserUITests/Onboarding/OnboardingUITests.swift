//
//  OnboardingUITests.swift
//  DebaserUITests
//
//  Created by Markus Bergh on 2021-07-15.
//

import XCTest

class OnboardingUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    private var skipButton: XCUIElement {
        return OnboardingScreen.skipButton.element
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments = ["-resetUserDefaults", "-testOnboarding"]
        app.launch()
    }

    override func tearDown() {
        app.terminate()
    }
    
    func testOnboardingDidShow() throws {
        XCTAssert(OnboardingScreen.onboardingStep1Title.element.waitForExistence(timeout: 10.0))
    }
    
    func testOnboardingHasPages() throws {
        app.swipeLeft()
        XCTAssert(OnboardingScreen.onboardingStep2Title.element.exists)
        
        app.swipeLeft()
        XCTAssert(OnboardingScreen.onboardingStep3Title.element.exists)
        
        app.swipeLeft()
        XCTAssert(OnboardingScreen.onboardingStep4Title.element.exists)
        
        // Final page should not have a skip button visible
        XCTAssertTrue(!skipButton.isHittable && !skipButton.exists)
    }
    
    func testOnboardingPushToSettingsView() throws {
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        
        XCTAssert(OnboardingScreen.spotifyButton.element.isHittable)
        OnboardingScreen.spotifyButton.element.tap()
        
        // User should end up in settings tab and pushed automatically to Spotify settings
        XCTAssert(app.staticTexts["Spotify"].waitForExistence(timeout: 10.0))
        XCTAssert(app.staticTexts["No active connection"].exists)
    }
        
}

enum OnboardingScreen: String {
    case onboardingStep1Title = "Use Spotify to preview"
    case onboardingStep2Title = "Share gigs with iMessage"
    case onboardingStep3Title = "Find that upcoming gig"
    case onboardingStep4Title = "Almost done! 🏄‍♀️ What is next?"
    
    case skipButton = "Skip"
    
    // Accessed by identifier
    case spotifyButton = "OnboardingSpotifyButton"

    var element: XCUIElement {
        switch self {
        case .onboardingStep1Title, .onboardingStep2Title, .onboardingStep3Title, .onboardingStep4Title:
            return XCUIApplication().staticTexts.matching(identifier: self.rawValue).element
        case .skipButton:
            return XCUIApplication().buttons.matching(identifier: self.rawValue).element
        case .spotifyButton:
            return XCUIApplication().buttons.matching(identifier: self.rawValue).element
        }
    }
}
