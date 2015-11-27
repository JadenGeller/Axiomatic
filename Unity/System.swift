//
//  System.swift
//  Unity
//
//  Created by Jaden Geller on 11/26/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public class System<Operator: Equatable, Argument: Equatable> {
    private let clauses: [Clause<Operator, Argument>]
    
    public init(clauses: [Clause<Operator, Argument>]) {
        self.clauses = clauses
    }
    
    public func query(goal: Predicate<Operator, Argument>) throws {
        for clause in clauses where clause.functor == goal.functor && clause.arity == goal.arity {
            do {
                switch clause {
                case .Fact(let predicate):
                    return try goal.unify(predicate)
                case .Rule:
                    fatalError("Not implemented")
                }
            }
            catch {
                continue
            }
        }
        throw UnificationError("Unable to unify.")
    }
}