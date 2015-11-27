//
//  Error.swift
//  Unity
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public struct UnificationError: ErrorType {
    internal init(_ message: String) {
        self.message = message
    }
    
    public let message: String
}