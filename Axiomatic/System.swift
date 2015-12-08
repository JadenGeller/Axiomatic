//
//  System.swift
//  Unity
//
//  Created by Jaden Geller on 11/26/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

extension SequenceType {
    func groupBy<Group: Hashable>(group: Generator.Element -> Group) -> [Group : [Generator.Element]] {
        var result: [Group : [Generator.Element]] = [:]
        forEach { element in
            result[group(element)] = (result[group(element)] ?? []) + [element]
        }
        return result
    }
}

extension Predicate {
    func solve(clauses: [ClauseSignature<Operator> : [Clause<Operator, Argument>]], then: () throws -> ()) throws {
        for clause in clauses[signature] ?? [] {
            let saved = snapshot()
            do {
                switch clause {
                case .Fact(let predicate):
                    try unify(predicate)
                case .Rule(let predicate, let dependencies):
                    try unify(predicate)
                    let solveDependencies = try dependencies.reduce({}) { (next: () throws -> (), predicate: Predicate<Operator, Argument>) throws -> (() throws -> ()) in
                        { try predicate.solve(clauses, then: next) }
                    }
                    try solveDependencies()
                }
                return try then()
            } catch _ as UnificationError {
                print("blah", self)
                saved.restore()
                continue
            }
        }
        throw UnificationError("Unable to unify")
    }
}

public class System<Operator: Hashable, Argument: Equatable> {
    private let clauses: [ClauseSignature<Operator> : [Clause<Operator, Argument>]]
    
    public init(clauses: [Clause<Operator, Argument>]) {
        self.clauses = clauses.groupBy { $0.signature }
    }
    
    public func unify(goals: [Predicate<Operator, Argument>]) throws {
        try goals.first!.solve(clauses, then: {
            print("WOOT")
        })
    }
//    
//        // WE WANT TO USE A CLEAN SYSTEM OF EVERY LOOP IN THE FOR LOOP SO WE CAN REUSE RULES
//        for clause in clauses where clause.functor == goal.functor && clause.arity == goal.arity {
//            do {
//                switch clause {
//                case .Fact(let predicate):
//                    return try goal.unify(predicate)
//                case .Rule(let predicate, let dependencies):
//                    try goal.unify(predicate)
//                    try dependencies.forEach(goal.unify)
//                }
//            }
//            catch {
//                continue
//            }
//        }
//        throw UnificationError("Unable to unify.")
//    }
}