//
//  Store.swift
//  FluxKit
//
//  Created by Dominique d'Argent on 26/05/15.
//  Copyright (c) 2015 Dominique d'Argent. All rights reserved.
//

import Foundation

public protocol StoreType {
    var dispatchToken: Token! { get }
}
