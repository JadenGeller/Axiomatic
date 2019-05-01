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
    /// The name of the term.
    public var name: Atom

    /// The arguments to the term, which are also terms themselves (except wrapped in a `Unifiable` to support
    /// recursive unification).
    public var arguments: [Unifiable<Term<Atom>>]

    /// Construct a compound term with the given `name` and `arguments`.
    public init(name: Atom, arguments: [Unifiable<Term<Atom>>]) {
        self.name = name
        self.arguments = arguments
    }

    /// Construct an atom.
    public init(atom: Atom) {
        name = atom
        arguments = []
    }
}

extension Term {
    /// The number of arguments of the term.
    public var arity: Int {
        return arguments.count
    }
}

extension Term: CustomStringConvertible {
    /// A textual represntation of `self`.
    public var description: String {
        guard arity > 0 else { return String(describing: name) }
        let args = arguments.map { String(describing: $0) }.joined(separator: ", ")
        return "\(name)(\(args))"
    }
}

extension Term: Equatable {
    /// Returns `true` if `lhs` and `rhs` have the same name and the same arguments. Note that the arguments are the same
    /// if they have the same value or if they are bound together.
    public static func ==(lhs: Term<Atom>, rhs: Term<Atom>) -> Bool {
        return lhs.name == rhs.name && lhs.arity == rhs.arity && zip(lhs.arguments, rhs.arguments).reduce(true) { result, pair in
            result && pair.0 == pair.1
        }
    }
}

extension Term: UnifiableType {
    /// Unifies `lhs` with `rhs`, recursively unifying their subtrees, else throws a `UnificationError`.
    public static func unify(_ lhs: Term, _ rhs: Term) throws {
        guard lhs.name == rhs.name else {
            throw UnificationError("Unable to unify functors with differing names \(lhs.name) and \(rhs.name).")
        }
        guard lhs.arity == rhs.arity else {
            throw UnificationError("Unable to unify functors with differing arity \(lhs.arity) and \(rhs.arity).")
        }
        try zip(lhs.arguments, rhs.arguments).forEach(Unifiable.unify)
    }

    /// Performs `action` as an operation on `self` such that the
    /// the unification status of the term will be unmodified if teh unification fails.
    public static func attempt(_ value: Term<Atom>, _ action: @escaping () throws -> ()) throws {
        let attemptAll = value.arguments.reduce(action) { (lambda: @escaping () throws -> (), term: Unifiable) in
            let newLambda = { try Unifiable.attempt(term, lambda) }
            return newLambda
        }
        try attemptAll()
    }
}

extension Term: ContextCopyable {
    /// Copies `this` reusing any substructure that has already been copied within
    /// this context, and storing any newly generated substructure into the context.
    public static func copy(_ this: Term, withContext context: CopyContext) -> Term {
        return Term(name: this.name, arguments: this.arguments.map { Unifiable<Term<Atom>>.copy($0, withContext: context) })
    }
}
