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
  private var clauses: [Functor<Atom>: [Clause<Atom>]]

  /// Constructs a `System` from a sequence of `Clause`s.
  public init<S: Sequence>(clauses: S) where S.Element == Clause<Atom> {
    self.clauses = clauses.groupBy { $0.head.functor }
  }

  /// Returns unique copies of the clauses that might bind with a `Term` of a given `functor`.
  private func uniqueClauses(functor: Functor<Atom>) -> LazyMapSequence<[Clause<Atom>], Clause<Atom>> {
    let nonUniqueClauses = clauses[functor] ?? []
    return nonUniqueClauses.lazy.map { Clause.copy($0, withContext: CopyContext()) }
  }
}

/// An exception thrown in the `enumerateMatches` callback that instructs whether the
/// system ought to continue enumerating matches or break prematurely.
public enum SystemException: Error {
  /// Continue enumerating matches.
  case Continue
  /// Break prematurely.
  case Break
}

extension System {
  /// Attempts to unify each term in `goals` with the known clauses in the system, calling `onMatch` each
  /// time it succeeds to simultaneously unify all `goals`.
  public func enumerateMatches(_ goals: [Term<Atom>], onMatch: @escaping () throws -> ()) throws {
    // Reverse first since reduce is right-to-left
    let satisfyAll = goals.reversed().reduce(onMatch) { lambda, predicate in { try self.enumerateMatches(predicate, onMatch: lambda) } }
    try satisfyAll()
  }

  /// Attempts to unify `goal` with the known clauses in the system calling `onMatch` each time it succeeds to unify.
  public func enumerateMatches(_ goal: Term<Atom>, onMatch: @escaping () throws -> ()) throws {
    var hasUnified = false
    // Enumerate all potential matches
    for clause in uniqueClauses(functor: goal.functor) {
      #if TRACE
      print("GOAL: \(goal)")
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
            hasUnified = true
            throw SystemException.Continue
          }
        }
        // We're out of possible clauses to unify, so I guess we're done.
        #if TRACE
        print("DONE")
        #endif
      } catch let exception as SystemException {
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
      } catch let error as UnificationError {
        #if TRACE
        print("BACKTRACKING: \(error)")
        #endif
        continue
      }
    }

    guard hasUnified else {
      throw UnificationError("No unification happened")
    }
  }
}
