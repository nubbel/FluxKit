//
//  FlightDispatcherViewController.swift
//  Example
//
//  Created by Dominique d'Argent on 20/05/15.
//  Copyright (c) 2015 Dominique d'Argent. All rights reserved.
//

import UIKit
import FluxKit

// MARK: - Flight Dispatcher View Controller

class FlightDispatcherViewController: UIViewController {

    let flux = FlightDispatcherFlux()
    var listeners: [AnyObject] = []
    
    @IBOutlet weak var countrySelect: UISegmentedControl!
    @IBOutlet weak var citySelect: UISegmentedControl!
    @IBOutlet weak var priceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register for store events
        listeners.append(flux.notificationCenter.addObserverForName(CountryStore.ChangeEvent, object: nil, queue: nil) { [unowned self] _ in
            self.renderView()
        })
        listeners.append(flux.notificationCenter.addObserverForName(CityStore.ChangeEvent, object: nil, queue: nil) { [unowned self] _ in
            self.renderView()
        })
        listeners.append(flux.notificationCenter.addObserverForName(FlightPriceStore.ChangeEvent, object: nil, queue: nil) { [unowned self] _ in
            self.renderView()
        })
        
        
        // dispatch initial action
        flux.flightDispatcherActions.updateCountry("china")
        
        // render
        renderView()
    }
    
    deinit {
        for listener in listeners {
            flux.notificationCenter.removeObserver(listener)
        }
    }
    
}

// MARK: - View rendering

extension FlightDispatcherViewController {
    func renderView() {
        countrySelect.items = [String](flightPrices.keys)
        countrySelect.selectedItem = flux.countryStore.country
        
        if let country = flux.countryStore.country {
            citySelect.items = citiesForCountry(country)
        }
        citySelect.selectedItem = flux.cityStore.city
        
        if let price = flux.flightPriceStore.price {
            priceLabel.text = "$ \(price)"
        }
    }
}

// MARK: View event handling

extension FlightDispatcherViewController {
    
    @IBAction func countryChanged(sender: AnyObject) {
        if let country = countrySelect.selectedItem {
            flux.flightDispatcherActions.updateCountry(country)
        }
    }
    
    @IBAction func cityChanged(sender: AnyObject) {
        if let city = citySelect.selectedItem {
            flux.flightDispatcherActions.updateCity(city)
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
            if let item = newValue, index = items.indexOf(item) {
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
        
        for (index, item) in items.enumerate() {
            setTitle(item, forSegmentAtIndex: index)
        }
    }

}

