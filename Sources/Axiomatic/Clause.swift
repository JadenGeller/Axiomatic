//
//  Clause.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Gluey

/// A statement whose `head` is true given that its `body` is true. When the `body` is empty,
/// a clause is commonly called a "fact". Otherwise, it is called a "rule". `Clause` is often
/// used with unification variables such that conditional truths can be expressed, such as
/// `grandparent(A, B) :- parent(A, X), parent(X, B)`.
public struct Clause<Atom: Hashable> {
    /// The term that is true conditional on all terms of the `body` being true.
    public var head: Term<Atom>

    /// The collection of terms that all must be true in order for `head` to be true.
    public var body: [Term<Atom>]

    private init(head: Term<Atom>, body: [Term<Atom>]) {
        self.head = head
        self.body = body
    }
}

extension Clause {
    /// Constructs a `Clause` that is always true.
    public init(fact: Term<Atom>) {
        self.init(head: fact, body: [])
    }

    /// Constructs a `Clause` that defines a rule that is true given some set of `conditions`.
    public init(rule: Term<Atom>, conditions: [Term<Atom>]) {
        self.init(head: rule, body: conditions)
    }
}

extension Clause: CustomStringConvertible {
    /// A textual description of `self`.
    public var description: String {
        guard body.count > 0 else { return head.description + "." }
        return head.description + " :- " + body.map { String(describing: $0) }.joined(separator: ", ") + "."
    }
}

// Bindings used in a `Clause` are expected to remain local to a clause. As such, initializers that properly scope needed bindings
// are provided for convenience and correctness.
extension Clause {
    /// Constructs a `Clause` that defines a rule that is true given some set of `conditions`
    /// using the `build` closure that provides 0 unused bindings.
    public init(build: () -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build()
        self.init(rule: rule, conditions: conditions)
    }

    /// Constructs a `Clause` that defines a rule that is true given some set of `conditions`
    /// using the `build` closure that provides 1 unused bindings.
    public init(build: (Binding<Term<Atom>>) -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding())
        self.init(rule: rule, conditions: conditions)
    }

    /// Constructs a `Clause` that defines a rule that is true given some set of `conditions`
    /// using the `build` closure that provides 2 unused bindings.
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>) -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }

    /// Constructs a `Clause` that defines a rule that is true given some set of `conditions`
    /// using the `build` closure that provides 3 unused bindings.
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }

    /// Constructs a `Clause` that defines a rule that is true given some set of `conditions`
    /// using the `build` closure that provides 4 unused bindings.
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }

    /// Constructs a `Clause` that defines a rule that is true given some set of `conditions`
    /// using the `build` closure that provides 5 unused bindings.
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }

    /// Constructs a `Clause` that defines a rule that is true given some set of `conditions`
    /// using the `build` closure that provides 6 unused bindings.
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding(), Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }
}

extension Clause {
    /// Constructs a `Clause` that defines a fact using the `build` closure that provides 0 unused bindings.
    public init(build: () -> Term<Atom>) {
        self.init(fact: build())
    }

    /// Constructs a `Clause` that defines a fact using the `build` closure that provides 1 unused bindings.
    public init(build: (Binding<Term<Atom>>) -> Term<Atom>) {
        self.init(fact: build(Binding()))
    }

    /// Constructs a `Clause` that defines a fact using the `build` closure that provides 2 unused bindings.
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>) -> Term<Atom>) {
        self.init(fact: build(Binding(), Binding()))
    }

    /// Constructs a `Clause` that defines a fact using the `build` closure that provides 3 unused bindings.
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> Term<Atom>) {
        self.init(fact: build(Binding(), Binding(), Binding()))
    }

    /// Constructs a `Clause` that defines a fact using the `build` closure that provides 4 unused bindings.
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> Term<Atom>) {
        self.init(fact: build(Binding(), Binding(), Binding(), Binding()))
    }

    /// Constructs a `Clause` that defines a fact using the `build` closure that provides 5 unused bindings.
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> Term<Atom>) {
        self.init(fact: build(Binding(), Binding(), Binding(), Binding(), Binding()))
    }

    /// Constructs a `Clause` that defines a fact using the `build` closure that provides 6 unused bindings.
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> Term<Atom>) {
        self.init(fact: build(Binding(), Binding(), Binding(), Binding(), Binding(), Binding()))
    }
}

extension Clause: ContextCopyable {
    /// Copies `this` reusing any substructure that has already been copied within
    /// this context, and storing any newly generated substructure into the context.
    public static func copy(_ this: Clause, withContext context: CopyContext) -> Clause {
        return Clause(head: Term.copy(this.head, withContext: context), body: this.body.map { Term.copy($0, withContext: context) })
    }
}
