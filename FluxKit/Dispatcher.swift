//
//  Dispatcher.swift
//  FluxKit
//
//  Created by Dominique d'Argent on 16/05/15.
//  Copyright (c) 2015 Dominique d'Argent. All rights reserved.
//

import Foundation

public class Dispatcher<Action : ActionType> {
    
    public typealias Token = String
    public typealias Callback = Action -> Void
    
    private var tokenGenerator : TokenStream.Generator
    
    private var isDispatching : Bool = false
    private var pendingAction : Action?
    private var callbacks : [Token: Callback] = [:]
    
    private var dispatchTokens : Set<Token> { return Set(callbacks.keys) }
    private var pendingDispatchTokens : Set<Token> = []
    private var handledDispatchTokens : Set<Token> = []
    
    
    public init() {
        tokenGenerator = TokenStream(prefix: "ID_").generate()
    }
    
    public func register(callback: Callback) -> Token {
        if let token = tokenGenerator.next() {
            callbacks[token] = callback
            
            return token
        }
        
        preconditionFailure("FluxKit.Dispatcher: Failed to generate new dispatch token.")
    }
    
    public func unregister(dispatchToken: Token) {
        precondition(isRegistered(dispatchToken), "FluxKit.Dispatcher: Unknown dispatch token \(dispatchToken).")
        
        callbacks.removeValueForKey(dispatchToken)
    }
    
    public func dispatch(action: Action) {
        precondition(!isDispatching, "FluxKit.Dispatcher: Cannot dispatch while dispatching.")
        
        beginDispatching(action)
        
        for dispatchToken in dispatchTokens {
            if isPending(dispatchToken) {
                continue
            }
            
            invokeCallback(dispatchToken)
        }
        
        endDispatching()
    }
    
    public func waitFor(dispatchTokens: Token...) {
        waitFor(dispatchTokens)
    }
    
    public func waitFor(dispatchTokens: [Token]) {
        for dispatchToken in dispatchTokens {
            if isPending(dispatchToken) {
                precondition(isHandled(dispatchToken), "FluxKit.Dispatcher: Circular dependency detected while waiting for \(dispatchToken).")
                
                continue
            }
            
            invokeCallback(dispatchToken)
        }
    }
}

private extension Dispatcher {
    func beginDispatching(action: Action) {
        isDispatching = true
        pendingAction = action
        pendingDispatchTokens = []
        handledDispatchTokens = []
    }
    
    func endDispatching() {
        isDispatching = false
        pendingAction = nil
    }
    
    func invokeCallback(dispatchToken: Token) {
        precondition(isDispatching, "FluxKit.Dispatcher: Not dispatching.")
        precondition(pendingAction != nil, "FluxKit.Dispatcher: Action missing.")
        precondition(isRegistered(dispatchToken), "FluxKit.Dispatcher: Unknown dispatch token \(dispatchToken).")
        
        if let action = pendingAction, callback = callbacks[dispatchToken] {
            pendingDispatchTokens.insert(dispatchToken)
            callback(action)
            handledDispatchTokens.insert(dispatchToken)
        }
    }
    
    func isRegistered(dispatchToken: Token) -> Bool {
        return callbacks[dispatchToken] != nil
    }
    
    func isPending(dispatchToken: Token) -> Bool {
        return pendingDispatchTokens.contains(dispatchToken)
    }
    
    func isHandled(dispatchToken: Token) -> Bool {
        return handledDispatchTokens.contains(dispatchToken)
    }
}


