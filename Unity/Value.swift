//
//  Fact.swift
//  Unity
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

internal protocol Unifiable {
    static func unify(lhs: Self, _ rhs: Self) throws
}

public enum Value<Raw: Equatable>: Equatable {
    case Literal(Raw)
    case Variable(Unity.Variable<Raw>)
    
    var value: Raw? {
        switch self {
        case .Literal(let value):
            return value
        case .Variable(let variable):
            return variable.value
        }
    }
    
    static func unify(lhs: Value, _ rhs: Value) throws {
        switch (lhs, rhs) {
        case (.Literal(let l), .Literal(let r)):
            guard l == r else {
                throw UnificationError("Cannot unify literals of different values.")
            }
        case (.Variable(let l), .Literal(let r)):
            try l.resolve(r)
        case (.Literal(let l), .Variable(let r)):
            try r.resolve(l)
        case (.Variable(let l), .Variable(let r)):
            try Unity.Variable.bind([l, r])
        }
    }
}

// DUPLICATE CODE IS GROSS
extension Value where Raw: Unifiable {
    static func unify(lhs: Value, _ rhs: Value) throws {
        switch (lhs, rhs) {
        case (.Literal(let l), .Literal(let r)):
            try Raw.unify(l, r)
        case (.Variable(let l), .Literal(let r)):
            try l.resolve(r)
        case (.Literal(let l), .Variable(let r)):
            try r.resolve(l)
        case (.Variable(let l), .Variable(let r)):
            try Unity.Variable.bind([l, r])
        }
    }
}

public func ==<Raw>(lhs: Value<Raw>, rhs: Value<Raw>) -> Bool {
    return lhs.value == rhs.value
}