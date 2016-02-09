//
//  Term.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Gluey

/// The data type used to represent atoms and compound terms. Takes the form `bar` or `foo(bazz, buzz)` for any arity.
/// Note that an atom is just a special case of a compound term with 0 arguments.
public struct Term<Atom: Hashable> {
    /// The name of the term
    public var name: Atom
    
    /// The arguments to the term, which are also terms themselves (except wrapped in a `Unifiable` wrapper
    public var arguments: [Unifiable<Term<Atom>>]
    
    public init(name: Atom, arguments: [Unifiable<Term<Atom>>]) {
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

extension Term: UnifiableType {
    public static func unify(lhs: Term, _ rhs: Term) throws {
        guard lhs.name == rhs.name else {
            throw UnificationError("Unable to unify functors with differing names \(lhs.name) and \(rhs.name).")
        }
        guard lhs.arity == rhs.arity else {
            throw UnificationError("Unable to unify functors with differing arity \(lhs.arity) and \(rhs.arity).")
        }
        try zip(lhs.arguments, rhs.arguments).forEach(Unifiable.unify)
    }
    
    public static func attempt(value: Term, _ action: () throws -> ()) throws {
        let attemptAll = value.arguments.reduce(action) { (lambda: () throws -> (), term: Unifiable) in
            let newLambda = { try Unifiable.attempt(term, lambda) }
            return newLambda
        }
        try attemptAll()
    }
}

extension Term: ContextCopyable {
    public static func copy(this: Term, withContext context: CopyContext) -> Term {
        return Term(name: this.name, arguments: this.arguments.map{ Unifiable<Term<Atom>>.copy($0, withContext: context) })
    }
}
