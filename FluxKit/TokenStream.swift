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
    typealias Seed = Int
    
    let prefix : Token
    let seed : Seed
    
    init(prefix: Token, seed: Seed = 0) {
        self.prefix = prefix
        self.seed = seed
    }
}

extension TokenStream : SequenceType {
    func generate() -> GeneratorOf<Token> {
        var counter = seed
        
        return GeneratorOf {
            "\(self.prefix)\(counter++)"
        }
    }
}