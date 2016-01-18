//
//  Predicate.swift
//  Unity
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public struct Predicate<Operator: Hashable, Argument: Equatable> {
    let functor: Operator
    let arguments: [Unifiable<Value<Operator, Argument>>]
    
    var arity: Int {
        return arguments.count
    }
    
    public init(functor: Operator, arguments: [Unifiable<Value<Operator, Argument>>]) {
        self.functor = functor
        self.arguments = arguments
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

struct PredicateSnapshot<Operator: Hashable, Argument: Equatable> {
    let glueSnapshots: [GlueSnapshot<Value<Operator, Argument>>]
    
    func restore() {
        glueSnapshots.forEach{ $0.restore() }
    }
}

extension Predicate {
    func snapshot() -> PredicateSnapshot<Operator, Argument> {
        return PredicateSnapshot(glueSnapshots: arguments.map{ $0.snapshot() })
    }
}
