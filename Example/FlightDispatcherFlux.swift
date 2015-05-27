//
//  Flux.swift
//  Example
//
//  Created by Dominique d'Argent on 27/05/15.
//  Copyright (c) 2015 Dominique d'Argent. All rights reserved.
//

import Foundation
import FluxKit

// MARK: - Data

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

func citiesForCountry(country: String) -> [String] {
    return [String](flightPrices[country]!.keys)
}

func defaultCityForCountry(country: String) -> String {
    return citiesForCountry(country).first!
}

func flightPrice(country: String, city: String) -> Int {
    return flightPrices[country]![city]!
}

// MARK: - Stores

final class CountryStore: StoreType {
    static var ChangeEvent = "CountryStoreDidChange"
    
    private(set) var country: String?
    private(set) var dispatchToken: Token!
    
    init(flux: FlightDispatcherFlux) {
        dispatchToken = flux.flightDispatcher.register { action in
            switch action.name {
            case "countryUpdate":
                self.country = action.payload["selectedCountry"] as? String
                flux.notificationCenter.postNotificationName(CountryStore.ChangeEvent, object: self)
            default:
                break
            }
        }
    }
}

final class CityStore: StoreType {
    static var ChangeEvent = "CityStoreDidChange"
    
    private(set) var city: String?
    private(set) var dispatchToken: Token!
    
    init(flux: FlightDispatcherFlux) {
        dispatchToken = flux.flightDispatcher.register { action in
            switch action.name {
            case "countryUpdate":
                flux.flightDispatcher.waitFor(flux.countryStore.dispatchToken)
                
                self.city = defaultCityForCountry(flux.countryStore.country!)
                flux.notificationCenter.postNotificationName(CityStore.ChangeEvent, object: self)
            case "cityUpdate":
                self.city = action.payload["selectedCity"] as? String
                flux.notificationCenter.postNotificationName(CityStore.ChangeEvent, object: self)
            default:
                break
            }
        }
    }
}

final class FlightPriceStore: StoreType {
    static var ChangeEvent = "FlightPriceStoreDidChange"
    
    private(set) var price: Int?
    private(set) var dispatchToken: Token!
    
    init(flux: FlightDispatcherFlux) {
        dispatchToken = flux.flightDispatcher.register { action in
            switch action.name {
            case "countryUpdate", "cityUpdate":
                flux.flightDispatcher.waitFor(flux.countryStore.dispatchToken)
                flux.flightDispatcher.waitFor(flux.cityStore.dispatchToken)
                
                self.price = flightPrice(flux.countryStore.country!, flux.cityStore.city!)
                flux.notificationCenter.postNotificationName(FlightPriceStore.ChangeEvent, object: self)
            default:
                break
            }
        }
    }
}

// MARK: - Actions

struct Action: ActionType {
    let name: String
    let payload: [String: AnyObject]
}

struct FlightDispatcherActions {
    private(set) weak var flux: FlightDispatcherFlux!
    
    func updateCountry(country: String) {
        flux.flightDispatcher.dispatch(Action(name: "countryUpdate", payload: ["selectedCountry": country]))
    }
    
    func updateCity(city: String) {
        flux.flightDispatcher.dispatch(Action(name: "cityUpdate", payload: ["selectedCity": city]))
    }
}

final class FlightDispatcherFlux {
    let notificationCenter = NSNotificationCenter()
    let flightDispatcher = Dispatcher<Action>()
    
    // Stores
    private(set) var countryStore: CountryStore!
    private(set) var cityStore: CityStore!
    private(set) var flightPriceStore: FlightPriceStore!
    
    // Action creators
    private(set) var flightDispatcherActions: FlightDispatcherActions!
    
    init() {
        countryStore = CountryStore(flux: self)
        cityStore = CityStore(flux: self)
        flightPriceStore = FlightPriceStore(flux: self)
        flightDispatcherActions = FlightDispatcherActions(flux: self)
    }
}
