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
    
    private func uniqueClausesWithFunctor(functor: Functor<Atom>) -> LazyMapSequence<[Clause<Atom>], Clause<Atom>> {
        let nonUniqueClauses = clauses[functor] ?? []
        let context = CopyContext()
        return nonUniqueClauses.lazy.map { Clause.copy($0, withContext: context) }
    }
}

extension System {
    public func enumerateMatches(goals: [Term<Atom>], onMatch: () throws -> ()) throws {
        // Reverse first since reduce is right-to-left
        let satisfyAll = goals.reverse().reduce(onMatch) { lambda, predicate in { try self.enumerateMatches(predicate, onMatch: lambda) } }
        try satisfyAll()
    }
    
    public func enumerateMatches(goal: Term<Atom>, onMatch: () throws -> ()) throws {
        print("GOAL: \(goal)")
        for clause in uniqueClausesWithFunctor(goal.functor) {
            print("ATTEMPT: \(clause)")
            do {
                try Term.attempt(goal) {
                    try Term.unify(goal, clause.head)
                    print("CALL: \(clause.head)")
                    try self.enumerateMatches(clause.body) {
                        print("SUCCESS: \(clause.head)")
                        try onMatch()
                        throw UnificationError("CONTINUE") // We need a way to end early.
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
