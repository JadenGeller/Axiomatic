//
//  Clause.swift
//  Unity
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public enum Clause<Operator: Equatable, Argument: Equatable> {
    case Fact(Predicate<Operator, Argument>)
    case Rule(Predicate<Operator, Argument>, [Predicate<Operator, Argument>])
    
    // TODO: MAYBE JUST HAVE A MATCH PREDICATE ARGUMENT
    public var arity: Int {
        switch self {
        case .Fact(let predicate):
            return predicate.arity
        case .Rule(let predicate, _):
            return predicate.arity
        }
    }
    
    public var functor: Operator {
        switch self {
        case .Fact(let predicate):
            return predicate.functor
        case .Rule(let predicate, _):
            return predicate.functor
        }
    }
}