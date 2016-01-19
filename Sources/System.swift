//
//  System.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Gluey

extension SequenceType {
    private func groupBy<Group: Hashable>(group: Generator.Element -> Group) -> [Group : [Generator.Element]] {
        var result: [Group : [Generator.Element]] = [:]
        forEach { element in
            result[group(element)] = (result[group(element)] ?? []) + [element]
        }
        return result
    }
}

public struct System<Atom: Hashable> {
    private let clauses: [Functor<Atom> : [Clause<Atom>]]
}

extension System {
    public init<S: SequenceType where S.Generator.Element == Clause<Atom>>(clauses: S) {
        self.clauses = clauses.groupBy{ $0.head.functor }
    }
}

extension System {
    public func satisfy(predicates: [Predicate<Atom>], success: () throws -> () = {}) throws {
        let satisfyAll = predicates.reduce(success) { lambda, predicate in { try self.satisfy(predicate, success: lambda) } }
        try satisfyAll()
    }
    
    public func satisfy(predicate: Predicate<Atom>, success: () throws -> () = {}) throws {
        print(predicate)
        for clause in clauses[predicate.functor] ?? [] {
            print("ATTEMPT: \(clause)")
            do {
                try Predicate.attempt(predicate) {
                    try Predicate.unify(predicate, clause.head)
                    print("UNIFIED!")
                    try self.satisfy(clause.body, success: success)
                }
                return
            } catch let error as UnificationError {
                print("BACKTRACKING: \(error)")
                continue
            }
        }
    }
}
