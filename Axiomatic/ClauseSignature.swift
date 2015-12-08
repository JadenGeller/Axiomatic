//
//  ClauseSignature.swift
//  Axiomatic
//
//  Created by Jaden Geller on 12/8/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public struct ClauseSignature<Operator: Hashable>: Hashable {
    let functor: Operator
    let arity: Int
    
    public var hashValue: Int {
        return functor.hashValue ^ arity.hashValue
    }
}

public func ==<Operator: Equatable>(lhs: ClauseSignature<Operator>, rhs: ClauseSignature<Operator>) -> Bool {
    return lhs.functor == rhs.functor && lhs.arity == rhs.arity
}

extension Clause {
    var signature: ClauseSignature<Operator> {
        return ClauseSignature(functor: functor, arity: arity)
    }
}

extension Predicate {
    var signature: ClauseSignature<Operator> {
        return ClauseSignature(functor: functor, arity: arity)
    }
}