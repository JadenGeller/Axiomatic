//
//  Rule.swift
//  Unity
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public enum Predicate<Operator: Equatable, Argument: Equatable> {
    case Atom(Argument)
    indirect case Relation(functor: Operator, arguments: [Value<Predicate<Operator, Argument>>])
}

extension Predicate: Unifiable {
    static func unify(lhs: Predicate, _ rhs: Predicate) throws {
        switch (lhs, rhs) {
        case (.Atom(let l), .Atom(let r)):
            guard l == r else {
                throw UnificationError("Unable to unify different atoms.")
            }
        case (.Relation(let l), .Relation(let r)):
            guard l.functor == r.functor else {
                throw UnificationError("Unable to unify relations of different names.")
            }
            guard l.arguments.count == r.arguments.count else {
                throw UnificationError("Unable to unify relations of different arity.")
            }
            try zip(l.arguments, r.arguments).forEach { lhs, rhs in
                switch (lhs, rhs) {
                case (.Literal(let l), .Literal(let r)):
                    try unify(l, r)
                default:
                    try Value.unify(lhs, rhs)
                }
            }
        default:
            throw UnificationError("Unable to unify a relation with an atom.")
        }
    }
}

extension Predicate: Equatable {}
public func ==<Operator, Argument>(lhs: Predicate<Operator, Argument>, rhs: Predicate<Operator, Argument>) -> Bool {
    switch (lhs, rhs) {
    case (.Atom(let l), .Atom(let r)):
        return l == r
    case (.Relation(let l), .Relation(let r)):
        return l.functor == r.functor && l.arguments == r.arguments
    default:
        return false
    }
}

//
//extension Predicate {
//    static func unify(lhs: Predicate, _ rhs: Predicate) throws {
//        switch (lhs, rhs) {
//        case (.Atom(let l), .Atom(let r)):
//            try! UnificationValue.unify(l, r)
//        case (.Relation(let l), .Relation(let r)):

//            zip(l.arguments, r.arguments).forEach { try! UnificationValue.unify($0, $1) }
//        default:
//            throw UnificationError("Unable to unify an atom with a relation.")
//        }
//    }
//}