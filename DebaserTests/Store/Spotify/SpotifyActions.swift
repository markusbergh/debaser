//
//  SpotifyActions.swift
//  DebaserTests
//
//  Created by Markus Bergh on 2021-05-02.
//

import XCTest
@testable import Debaser

class SpotifyActionsTests: XCTestCase {
    var store: MockStore!
    
    static var calledWithAction: SpotifyAction?
    
    class MockStore: StoreProtocol {
        func dispatch(withAction action: SpotifyAction) {
            SpotifyActionsTests.calledWithAction = action
        }
    }
    
    override func setUp() {
        store = MockStore()
    }
    
    override func tearDown() {
        SpotifyActionsTests.calledWithAction = nil
    }
    
    func testActionInitialize() {
        let expectedAction: SpotifyAction = .initialize
        
        store.dispatch(withAction: .initialize)
        
        XCTAssertEqual(SpotifyActionsTests.calledWithAction, expectedAction)
    }
}
