//
//  Created by Volodymyr Andriienko on 11/3/21.
//  Copyright © 2021 VAndrJ. All rights reserved.
//

import XCTest
@testable import WeatherBrick

class WeatherBrickTests: XCTestCase {
    var vc: ViewController!
    
    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        vc.loadViewIfNeeded()
    }
    
    override func tearDown() {
        vc = nil
    }
    
    func testGetData() {
        let expectation = expectation(description: "Expectation in " + #function)
        vc.startLocationManager()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            expectation.fulfill()
        })
        waitForExpectations(timeout: 3, handler: nil)
        if let resultWeatherDescription = self.vc.weatherDescriptionLabel.text {
            XCTAssertNotEqual(resultWeatherDescription, "Осадки")
        }
        if let resultWeatherDescription = self.vc.tempLabel.text {
            XCTAssertNotEqual(resultWeatherDescription, "0")
        }
        if let resultWeatherDescription = self.vc.cityLabel.text {
            XCTAssertNotEqual(resultWeatherDescription, "Страна, город")
        }
    }
    
    
}


