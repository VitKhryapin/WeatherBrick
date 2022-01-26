//
//  Created by Vitaly Khryapin on 11/3/21.
//  Copyright © 2021 VAndrJ. All rights reserved.
//

import XCTest
import SnapshotTesting

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
        vc.updateWeatherInfo(latitude: 55.755786, longitude: 37.617633)
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
    
    func testSnapshotStartScreen() {
        isRecording = false
        assertSnapshot(matching: vc, as: .image)
        assertSnapshot(matching: vc, as: .image(on: .iPhone8))
        assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
    }
    
    func testSnapshotOpenInfo() {
        let expectation = expectation(description: "Expectation in " + #function)
        vc.startLocationManager()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            expectation.fulfill()
        })
        waitForExpectations(timeout: 3, handler: nil)
        vc.openInfoView()
        isRecording = false
        assertSnapshot(matching: vc, as: .image)
        assertSnapshot(matching: vc, as: .image(on: .iPhone8))
        assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
    }
}


