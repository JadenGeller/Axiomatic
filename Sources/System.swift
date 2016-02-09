//
//  System.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// Set to `true` to enable trace mode.
private let DEBUG = false

import Gluey

/// A logic `System`, defined by a collection of `Clauses`, that provides a mechanism for querying
/// to learn facts about the system.
public struct System<Atom: Hashable> {
    private let clauses: [Functor<Atom> : [Clause<Atom>]]
    
    /// Constructs a `System` from a sequence of `Clause`s.
    public init<S: SequenceType where S.Generator.Element == Clause<Atom>>(clauses: S) {
        self.clauses = clauses.groupBy{ $0.head.functor }
    }
    
    /// Returns unique copies of the clauses that might bind with a `Term` of a given `functor`.
    private func uniqueClausesWithFunctor(functor: Functor<Atom>) -> LazyMapSequence<[Clause<Atom>], Clause<Atom>> {
        let nonUniqueClauses = clauses[functor] ?? []
        let context = CopyContext()
        return nonUniqueClauses.lazy.map { Clause.copy($0, withContext: context) }
    }
}

extension System {
    /// Attempts to unify each term in `goals` with the known clauses in the system, calling `onMatch` each
    /// time it succeeds to simultaneously unify all `goals`.
    public func enumerateMatches(goals: [Term<Atom>], onMatch: () throws -> ()) throws {
        // Reverse first since reduce is right-to-left
        let satisfyAll = goals.reverse().reduce(onMatch) { lambda, predicate in { try self.enumerateMatches(predicate, onMatch: lambda) } }
        try satisfyAll()
    }
    
    /// Attempts to unify `goal` with the known clauses in the system calling `onMatch` each time it succeeds to unify.
    public func enumerateMatches(goal: Term<Atom>, onMatch: () throws -> ()) throws {
        #if debug
            print("GOAL: \(goal)")
        #endif
        for clause in uniqueClausesWithFunctor(goal.functor) {
            #if debug
            print("ATTEMPT: \(clause)")
            #endif
            do {
                try Term.attempt(goal) {
                    try Term.unify(goal, clause.head)
                    #if debug
                    print("CALL: \(clause.head)")
                    #endif
                    try self.enumerateMatches(clause.body) {
                        #if debug
                        print("SUCCESS: \(clause.head)")
                        #endif
                        try onMatch()
                        throw UnificationError("CONTINUE") // We need a way to end early.
                    }
                }
                #if debug
                print("DONE")
                #endif
                return
            } catch let error as UnificationError {
                #if debug
                print("BACKTRACKING: \(error)")
                #endif
                continue
            }
        }
    }
}
