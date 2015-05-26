//
//  TokenStream.swift
//  FluxKit
//
//  Created by Dominique d'Argent on 16/05/15.
//  Copyright (c) 2015 Dominique d'Argent. All rights reserved.
//

import Foundation

public typealias Token = String

struct TokenStream {
    private let prefix : Token
    private let seed : Int
    
    init(prefix: Token, seed: Int = 0) {
        self.prefix = prefix
        self.seed = seed
    }
}

extension TokenStream : CollectionType {
    var startIndex: Int { return seed }
    var endIndex:   Int { return Int.max }
    
    subscript(index: Int) -> Token {
        get {
            return "\(prefix)\(index)"
        }
    }
    
    func generate() -> IndexingGenerator<TokenStream> {
        return IndexingGenerator(self)
    }
}
