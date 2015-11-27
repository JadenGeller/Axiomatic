//
//  Value.swift
//  Axiomatic
//
//  Created by Jaden Geller on 11/26/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public enum Value<Operator: Equatable, Argument: Equatable> {
    case Atom(Argument)
    case Relation(Predicate<Operator, Argument>)
}

extension Value: UnifiableType {
    internal func unify(other: Value) throws {
        switch (self, other) {
        case (.Atom(let atom), .Atom(let otherAtom)):
            guard atom == otherAtom else {
                throw UnificationError("Unable to unify different atoms.")
            }
        case (.Relation(let predicate), .Relation(let otherPredicate)):
            try predicate.unify(otherPredicate)
        default:
            throw UnificationError("Unable to unify a relation with an atom.")
        }
    }
}

extension Value: Equatable {}
public func ==<Operator, Argument>(lhs: Value<Operator, Argument>, rhs: Value<Operator, Argument>) -> Bool {
    switch (lhs, rhs) {
    case (.Atom(let l), .Atom(let r)):
        return l == r
    case (.Relation(let l), .Relation(let r)):
        return l == r
    default:
        return false
    }
}
