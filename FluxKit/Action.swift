//
//  Action.swift
//  FluxKit
//
//  Created by Dominique d'Argent on 16/05/15.
//  Copyright (c) 2015 Dominique d'Argent. All rights reserved.
//

import Foundation

public struct Action {
    public typealias Payload = [String: Any]
    
    public let name: String
    public let payload: Payload
    public let timestamp: NSDate
    
    public init(name: String, payload: Payload, timestamp: NSDate = NSDate()) {
        self.name = name
        self.payload = payload
        self.timestamp = timestamp
    }
}