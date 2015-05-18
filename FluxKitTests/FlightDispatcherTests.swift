//
//  FlightDispatcherTests.swift
//  FluxKit
//
//  Created by Dominique d'Argent on 18/05/15.
//  Copyright (c) 2015 Dominique d'Argent. All rights reserved.
//

import UIKit
import XCTest
import FluxKit

// Adapted from https://gist.github.com/artisonian/83fd0ae1905c75af9c1b

let defaultCities = [
    "australia": "sydney",
    "china": "shanghai",
    "france": "paris",
    "india": "mumbai",
    "usa": "new york"
]

func defaultCityForCountry(country: String) -> String {
    return defaultCities[country]!
}

let flightPrices = [
    "australia": [
        "sydney": 1920
    ],
    "china": [
        "shanghai": 3280,
        "beijing": 2910
    ],
    "france": [
        "paris": 3300
    ],
    "india": [
        "mumbai": 2760
    ],
    "usa": [
        "new york": 2270,
        "chicago": 1780,
        "los angeles": 2190
    ]
]

func flightPrice(country: String, city: String) -> Int {
    return flightPrices[country]![city]!
}

struct CountryStore {
    var country: String?
    var dispatchToken: Token?
}

struct CityStore {
    var city: String?
    var dispatchToken: Token?
}

struct FlightPriceStore {
    var price: Int?
    var dispatchToken: Token?
}

class FlightDispatcherTests: XCTestCase {

    var flightDispatcher = Dispatcher()
    var countryStore = CountryStore()
    var cityStore = CityStore()
    var flightPriceStore = FlightPriceStore()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        countryStore.dispatchToken = flightDispatcher.registerCallback { [unowned self] action in
            switch action.name {
            case "countryUpdate":
                self.countryStore.country = action.payload["selectedCountry"] as? String
            default:
                break
            }
        }

        cityStore.dispatchToken = flightDispatcher.registerCallback { [unowned self] action in
            switch action.name {
            case "countryUpdate":
                self.flightDispatcher.waitFor(self.countryStore.dispatchToken!)
                self.cityStore.city = defaultCityForCountry(self.countryStore.country!)
            case "cityUpdate":
                self.cityStore.city = action.payload["selectedCity"] as? String
            default:
                break
            }
        }

        flightPriceStore.dispatchToken = flightDispatcher.registerCallback { [unowned self] action in
            switch action.name {
            case "countryUpdate", "cityUpdate":
                self.flightDispatcher.waitFor(self.cityStore.dispatchToken!)
                self.flightPriceStore.price = flightPrice(self.countryStore.country!, self.cityStore.city!)
            default:
                break
            }
        }
        
    }
    
    override func tearDown() {
        flightDispatcher.unregisterCallback(countryStore.dispatchToken!)
        flightDispatcher.unregisterCallback(cityStore.dispatchToken!)
        flightDispatcher.unregisterCallback(flightPriceStore.dispatchToken!)
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDispatching() {
        flightDispatcher.dispatch(Action(name: "countryUpdate", payload: ["selectedCountry": "china"]))
        XCTAssertEqual(
            [countryStore.country!, cityStore.city!, flightPriceStore.price!],
            ["china", "shanghai", 3280],
            "To shanghai, china: $3280.")
        
        flightDispatcher.dispatch(Action(name: "cityUpdate", payload: ["selectedCity": "beijing"]))
        XCTAssertEqual(
            [countryStore.country!, cityStore.city!, flightPriceStore.price!],
            ["china", "beijing", 2910],
            "To beijing, china: $2910.")
        
        flightDispatcher.dispatch(Action(name: "countryUpdate", payload: ["selectedCountry": "india"]))
        XCTAssertEqual(
            [countryStore.country!, cityStore.city!, flightPriceStore.price!],
            ["india", "mumbai", 2760],
            "To mumbai, india: $2760.")
    }

}
