//
//  OnboardingReducer.swift
//  DebaserTests
//
//  Created by Markus Bergh on 2021-05-03.
//

import Combine
import XCTest
@testable import Debaser

class OnboardingReducerTests: XCTestCase {
    private var cancellable: AnyCancellable?
    
    func testOnboardingInitial() {
        var initialState = OnboardingState()
        
        let newState = onboardingReducer(state: &initialState, action: .getOnboarding)
        
        XCTAssert(newState == initialState)
    }
    
    func testOnboardingSeen() {
        var initialState = OnboardingState()
        
        let expectedValue = false
        let expectation = XCTestExpectation(description: "Expected value was not received")

        let newState = onboardingReducer(state: &initialState, action: .showOnboarding)
        
        cancellable = newState.$seenOnboarding.sink(receiveValue: { value in
            XCTAssertEqual(value, expectedValue)
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 5.0)
    }
}
