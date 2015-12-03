//
//  Predicate.swift
//  Unity
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public struct Predicate<Operator: Equatable, Argument: Equatable> {
    let functor: Operator
    let arguments: [Unifiable<Value<Operator, Argument>>]
    
    var arity: Int {
        return arguments.count
    }
}

extension Predicate: UnifiableType {
    internal func unify(other: Predicate) throws {
        guard functor == other.functor else {
            throw UnificationError("Unable to unify relations of different names.")
        }
        guard arity == other.arity else {
            throw UnificationError("Unable to unify relations of different arity.")
        }
        try zip(arguments, other.arguments).forEach { try $0.unify($1) }
    }
}

extension Predicate: Equatable {}
public func ==<Operator, Argument>(lhs: Predicate<Operator, Argument>, rhs: Predicate<Operator, Argument>) -> Bool {
    return lhs.functor == rhs.functor && lhs.arguments == rhs.arguments
}