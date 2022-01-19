//
//  WeatherBrickUITests.swift
//  WeatherBrickTests
//
//  Created by Vitaly Khryapin on 19.01.2022.
//

import XCTest
import SnapshotTesting

class WeatherBrickUITests: XCTestCase {
    let app = XCUIApplication()
    override func setUp() {
           super.setUp()
           app.launch()
       }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }
    
    func verifyView(identifier: String, perPixelTolerance: CGFloat = 0.0, overallTolerance: CGFloat = 0.05 ) {
            
        _ = app.screenshot().image
        }

//    func testExample() throws {
//        let app = XCUIApplication()
//        app.launch()
//        let vc = UIViewController()
//            assertSnapshot(matching: vc, as: .image)
//    }

}
