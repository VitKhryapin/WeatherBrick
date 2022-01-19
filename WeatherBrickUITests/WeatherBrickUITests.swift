//
//  Created by Volodymyr Andriienko on 11/3/21.
//  Copyright © 2021 VAndrJ. All rights reserved.
//
import SnapshotTesting
import XCTest

@testable import WeatherBrick

class WeatherBrickUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        let vc = ViewController()
        assertSnapshot(matching: vc, as: .image)
    }
}
