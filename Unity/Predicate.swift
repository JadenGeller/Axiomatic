//
//  Rule.swift
//  Unity
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

//indirect enum Predicate<Operator: Equatable, Argument: Equatable>: Equatable {
//    case Atom(UnificationValue<Argument>)
//    case Relation(functor: Operator, arguments: [UnificationValue<Predicate<Operator, Argument>>])
//}
//
//func ==<Operator, Argument>(lhs: Predicate<Operator, Argument>, rhs: Predicate<Operator, Argument>) -> Bool {
//    switch (lhs, rhs) {
//    case (.Atom(let l), .Atom(let r)):
//        return l == r
//    case (.Relation(let l), .Relation(let r)):
//        return l.functor == r.functor && l.arguments == r.arguments
//    default:
//        return false
//    }
//}
//
//extension Predicate {
//    static func unify(lhs: Predicate, _ rhs: Predicate) throws {
//        switch (lhs, rhs) {
//        case (.Atom(let l), .Atom(let r)):
//            try! UnificationValue.unify(l, r)
//        case (.Relation(let l), .Relation(let r)):
//            guard l.functor == r.functor else {
//                throw UnificationError("Unable to unify relations of different names.")
//            }
//            guard l.arguments.count == r.arguments.count else {
//                throw UnificationError("Unable to unify relations of different arity.")
//            }
//            zip(l.arguments, r.arguments).forEach { try! UnificationValue.unify($0, $1) }
//        default:
//            throw UnificationError("Unable to unify an atom with a relation.")
//        }
//    }
//}