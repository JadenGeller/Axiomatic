//
//  System.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Gluey

/// A logic `System`, defined by a collection of `Clauses`, that provides a mechanism for querying
/// to learn facts about the system.
public struct System<Atom: Hashable> {
    private var clauses: [Functor<Atom> : [Clause<Atom>]]
    
    /// Constructs a `System` from a sequence of `Clause`s.
    public init<S: SequenceType where S.Generator.Element == Clause<Atom>>(clauses: S) {
        self.clauses = clauses.groupBy{ $0.head.functor }
    }
    
    /// Returns unique copies of the clauses that might bind with a `Term` of a given `functor`.
    private func uniqueClausesWithFunctor(functor: Functor<Atom>) -> LazyMapSequence<[Clause<Atom>], Clause<Atom>> {
        let nonUniqueClauses = clauses[functor] ?? []
        return nonUniqueClauses.lazy.map { Clause.copy($0, withContext: CopyContext()) }
    }
}

public enum SystemException: UnificationErrorType {
    case Continue
    case Break
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
        #if TRACE
            print("GOAL: \(goal)")
        #endif
        // Enumerate all potential matches
        for clause in uniqueClausesWithFunctor(goal.functor) {
            #if TRACE
            print("ATTEMPT: \(clause)")
            #endif
            do {
                // For each match, attempt to unify, backtracking on failure
                try Term.attempt(goal) {
                    try Term.unify(goal, clause.head)
                    #if TRACE
                    print("CALL: \(clause.head)")
                    #endif
                    // If we're able to unify the head, attempt to unify the entire body
                    try self.enumerateMatches(clause.body) {
                        #if TRACE
                        print("SUCCESS: \(clause.head)")
                        #endif
                        
                        // We've unfied a clause, so let's report it!
                        try onMatch()
                        throw SystemException.Continue
                    }
                }
                // We're out of possible clauses to unify, so I guess we're done.
                #if TRACE
                print("DONE")
                #endif
                return
            }
            // Now that we've gotten that figured out, another round?
            catch let exception as SystemException {
                switch exception {
                case .Break:
                    #if TRACE
                        print("BREAK")
                    #endif
                    // Nah bra
                    return
                case .Continue:
                    #if TRACE
                        print("CONTINUING")
                    #endif
                    // Most def
                    continue
                }
            }
            // Looks like that clause didn't work out, let's try the next...
            catch let error as UnificationError {
                #if TRACE
                print("BACKTRACKING: \(error)")
                #endif
                continue
            }
        }
    }
}
