//
//  Unifiable.swift
//  Unity
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

internal protocol UnifiableType {
    func unify(other: Self) throws
}

extension UnifiableType {
//    static func unify(values: [Self]) throws {
//        for (lhs, rhs) in zip(values, values.dropFirst()) {
//            try lhs.unify(rhs)
//        }
//    }
    static func unify(lhs: Self, _ rhs: Self) throws {
        try lhs.unify(rhs)
    }
}

public enum Unifiable<Value: Equatable>: Equatable, UnifiableType {
    case Literal(Value)
    case Variable(Binding<Value>)
    
    public var value: Value? {
        switch self {
        case .Literal(let value):
            return value
        case .Variable(let binding):
            return binding.value
        }
    }
    
    internal func unify(other: Unifiable) throws {
        try _unify(other)
    }
    
    internal func _unify(other: Unifiable) throws {
        switch (self, other) {
        case (.Literal(let value), .Literal(let otherValue)):
            guard value == otherValue else {
                throw UnificationError("Cannot unify literals of different values.")
            }
        case (.Variable(let binding), .Literal(let value)):
            try binding.resolve(value)
        case (.Literal(let value), .Variable(let binding)):
            try binding.resolve(value)
        case (.Variable(let binding), .Variable(let otherBinding)):
            try binding.bind(otherBinding)
        }
    }
}

extension Unifiable where Value: UnifiableType {
    func unify(other: Unifiable) throws {
        switch (self, other) {
        case (.Literal(let unifiableValue), .Literal(let otherUnifiableValue)):
            // Recursively unify based on the structure of Value
            try unifiableValue.unify(otherUnifiableValue)
        default:
            try _unify(other)
        }
    }
}

public func ==<Value>(lhs: Unifiable<Value>, rhs: Unifiable<Value>) -> Bool {
    return lhs.value == rhs.value
}

extension Unifiable {
    func snapshot() -> GlueSnapshot<Value> {
        switch self {
        case .Literal:
            return GlueSnapshot.empty()
        case .Variable(let binding):
            return binding.snapshot()
        }
    }
}
