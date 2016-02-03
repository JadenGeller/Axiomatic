//
//  Term.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Gluey

public struct Term<Atom: Hashable> {
    public var name: Atom
    public var arguments: [Value<Term<Atom>>]
    
    public init(name: Atom, arguments: [Value<Term<Atom>>]) {
        self.name = name
        self.arguments = arguments
    }
    
    public init(atom: Atom) {
        self.name = atom
        self.arguments = []
    }
}

extension Term {
    public var arity: Int {
        return arguments.count
    }
}

extension Term: CustomStringConvertible {
    public var description: String {
        guard arity > 0 else { return String(name) }
        let args = arguments.map{ String($0) }.joinWithSeparator(", ")
        return "\(name)(\(args))"
    }
}

extension Term: Equatable {}
public func ==<Atom: Hashable>(lhs: Term<Atom>, rhs: Term<Atom>) -> Bool {
    return lhs.name == rhs.name && lhs.arity == rhs.arity && zip(lhs.arguments, rhs.arguments).reduce(true) { result, pair in
        result && pair.0 == pair.1
    }
}

extension Term: Unifiable {
    public static func unify(lhs: Term, _ rhs: Term) throws {
        guard lhs.name == rhs.name else {
            print("LHS", lhs)
            print("RHS", rhs)
            throw UnificationError("Unable to unify functors with differing names \(lhs.name) and \(rhs.name).")
        }
        guard lhs.arity == rhs.arity else {
            throw UnificationError("Unable to unify functors with differing arity \(lhs.arity) and \(rhs.arity).")
        }
        try zip(lhs.arguments, rhs.arguments).forEach(Value.unify)
    }
    
    public static func attempt(value: Term, _ action: () throws -> ()) throws {
        let attemptAll = value.arguments.reduce(action) { (lambda: () throws -> (), term: Value) in
            let newLambda = { try Value.attempt(term, lambda) }
            return newLambda
        }
        try attemptAll()
    }
}

extension Term: ContextCopyable {
    public static func copy(this: Term, withContext context: CopyContext) -> Term {
        return Term(name: this.name, arguments: this.arguments.map{ Value<Term<Atom>>.copy($0, withContext: context) })
    }
}
