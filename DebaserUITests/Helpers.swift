//
//  Helpers.swift
//  DebaserUITests
//
//  Created by Markus Bergh on 2021-07-15.
//

import XCTest

extension XCUIElement {
    func tapUnhittable() {
        XCTContext.runActivity(named: "Tap \(self) by coordinate") { _ in
            coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0)).tap()
        }
    }
}
