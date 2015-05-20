//
//  FlightDispatcherViewController.swift
//  Example
//
//  Created by Dominique d'Argent on 20/05/15.
//  Copyright (c) 2015 Dominique d'Argent. All rights reserved.
//

import UIKit
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

// MARK: - Flight Dispatcher View Controller

class FlightDispatcherViewController: UIViewController {

    let flightDispatcher : Dispatcher = Dispatcher()
    
    var countryStore : CountryStore = CountryStore() {
        // poor man's EventEmitter
        didSet {
            countryStoreChanged(oldValue)
        }
    }
    
    var cityStore : CityStore = CityStore() {
        // poor man's EventEmitter
        didSet {
            cityStoreChanged(oldValue)
        }
    }
    
    var flightPriceStore : FlightPriceStore = FlightPriceStore() {
        // poor man's EventEmitter
        didSet {
            flightPriceStoreChanged(oldValue)
        }
    }
    
    @IBOutlet weak var countrySelect: UISegmentedControl!
    @IBOutlet weak var citySelect: UISegmentedControl!
    @IBOutlet weak var priceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // register callbacks
        
        countryStore.dispatchToken = flightDispatcher.register { [unowned self] action in
            switch action.name {
            case "countryUpdate":
                self.countryStore.country = action.payload["selectedCountry"] as? String
            default:
                break
            }
        }
        
        cityStore.dispatchToken = flightDispatcher.register { [unowned self] action in
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
        
        flightPriceStore.dispatchToken = flightDispatcher.register { [unowned self] action in
            switch action.name {
            case "countryUpdate", "cityUpdate":
                self.flightDispatcher.waitFor(self.cityStore.dispatchToken!)
                self.flightPriceStore.price = flightPrice(self.countryStore.country!, self.cityStore.city!)
            default:
                break
            }
        }
        
        // dispatch initial action
        flightDispatcher.dispatch(Action(name: "countryUpdate", payload: ["selectedCountry": "china"]))
    }
    
    deinit {
        flightDispatcher.unregister(countryStore.dispatchToken!)
        flightDispatcher.unregister(cityStore.dispatchToken!)
        flightDispatcher.unregister(flightPriceStore.dispatchToken!)
    }
}


// MARK: Store event handling

extension FlightDispatcherViewController {
    func countryStoreChanged(oldValue: CountryStore) {
        if countryStore.country != oldValue.country {
            citySelect.items = citiesForCountry(countryStore.country!)
            countrySelect.selectedItem = countryStore.country
        }
    }
    
    func cityStoreChanged(oldValue: CityStore) {
        if cityStore.city != oldValue.city {
            citySelect.selectedItem = cityStore.city
        }
    }
    
    func flightPriceStoreChanged(oldValue: FlightPriceStore) {
        if flightPriceStore.price != oldValue.price {
            priceLabel.text = "$ \(flightPriceStore.price!)"
        }
    }
    
}


// MARK: View event handling

extension FlightDispatcherViewController {
    
    @IBAction func countryChanged(sender: AnyObject) {
        let index = countrySelect.selectedSegmentIndex
        
        if let country = countrySelect.selectedItem {
            flightDispatcher.dispatch(Action(name: "countryUpdate", payload: ["selectedCountry": country]))
        }
    }
    
    @IBAction func cityChanged(sender: AnyObject) {
        let index = citySelect.selectedSegmentIndex
        
        if let city = citySelect.selectedItem {
            flightDispatcher.dispatch(Action(name: "cityUpdate", payload: ["selectedCity": city]))
        }
    }
}


// Mark: - UISegmentedControl helper

extension UISegmentedControl {
    var items : [String] {
        get {
            return (0..<numberOfSegments).map { self.titleForSegmentAtIndex($0)! }
        }
        set {
            setItems(newValue, animated: false)
        }
    }
    
    var selectedItem : String? {
        get {
            return titleForSegmentAtIndex(selectedSegmentIndex)
        }
        set {
            if let item = newValue, index = find(items, item) {
                selectedSegmentIndex = index
            } else {
                selectedSegmentIndex = UISegmentedControlNoSegment
            }
        }
    }
    
    func setItems(items: [String], animated: Bool) {
        while numberOfSegments - items.count > 0 {
            removeSegmentAtIndex(0, animated: animated)
        }
        
        while items.count - numberOfSegments > 0 {
            insertSegmentWithTitle("", atIndex: 0, animated: animated)
        }
        
        for (index, item) in enumerate(items) {
            setTitle(item, forSegmentAtIndex: index)
        }
    }

}

