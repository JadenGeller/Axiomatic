//
//  Fact.swift
//  Unity
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

enum UnificationValue<Value: Equatable>: Equatable {
    case Literal(Value)
    case Variable(Unity.Variable<Value>)
    
    var value: Value? {
        switch self {
        case .Literal(let value):
            return value
        case .Variable(let variable):
            return variable.value
        }
    }
    
    static func unify(lhs: UnificationValue, _ rhs: UnificationValue) throws {
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

func ==<Value>(lhs: UnificationValue<Value>, rhs: UnificationValue<Value>) -> Bool {
    return lhs.value == rhs.value
}