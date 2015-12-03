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
        // WE WANT TO USE A CLEAN SYSTEM OF EVERY LOOP IN THE FOR LOOP SO WE CAN REUSE RULES
        for clause in clauses where clause.functor == goal.functor && clause.arity == goal.arity {
            do {
                switch clause {
                case .Fact(let predicate):
                    return try goal.unify(predicate)
                case .Rule(let predicate, let dependencies):
                    try goal.unify(predicate)
                    
                    // NOTE; WE NEED TO MAKE A CLEAN COPY OF OUR SYSTEM FOR EACH RECURSE
                    // BC WE MIGHT WANT TO REUSE A RULE THAT HAS ALREADY BEEN UNIFIED TO
                    try dependencies.forEach(goal.unify)
                }
            }
            catch {
                continue
            }
        }
        throw UnificationError("Unable to unify.")
    }
}