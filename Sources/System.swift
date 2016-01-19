//
//  System.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Gluey

public struct System<Atom: Hashable> {
    private let clauses: [Functor<Atom> : [Clause<Atom>]]
    
    public init<S: SequenceType where S.Generator.Element == Clause<Atom>>(clauses: S) {
        self.clauses = clauses.groupBy{ $0.head.functor }
    }
    
//    private func uniqueClausesWithFunctor(functor: Functor<Atom>) -> [Clause<Atom>] {
//        let nonUniqueClauses = clauses[functor] ?? []
//        return nonUniqueClauses.map{  }
//    }
}

extension System {
    public func enumerateMatches(goals: [Predicate<Atom>], onMatch: () throws -> ()) throws {
        let satisfyAll = goals.reduce(onMatch) { lambda, predicate in { try self.enumerateMatches(predicate, onMatch: lambda) } }
        try satisfyAll()
    }
    
    public func enumerateMatches(goal: Predicate<Atom>, onMatch: () throws -> ()) throws {
        print("GOAL: \(goal)")
        for clause in clauses[goal.functor] ?? [] {
            print("ATTEMPT: \(clause)")
            do {
                try Predicate.attempt(goal) {
                    try Predicate.unify(goal, clause.head)
                    print("CALL: \(clause.head)")
                    try self.enumerateMatches(clause.body) {
                        print("SUCCESS: \(clause.head)")
                        try onMatch()
                        throw UnificationError("CONTINUE")
                    }
                }
                print("DONE")
                return
            } catch let error as UnificationError {
                print("BACKTRACKING: \(error)")
                continue
            }
        }
    }
}
