//
//  Clause.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Gluey

public struct Clause<Atom: Hashable> {
    public var head: Term<Atom>
    public var body: [Term<Atom>]

    private init(head: Term<Atom>, body: [Term<Atom>]) {
        self.head = head
        self.body = body
    }
}

extension Clause {
    public init(fact: Term<Atom>) {
        self.init(head: fact, body: [])
    }
    
    public init(rule: Term<Atom>, conditions: [Term<Atom>]) {
        self.init(head: rule, body: conditions)
    }
}

extension Clause: CustomStringConvertible {
    public var description: String {
        guard body.count > 0 else { return head.description + "." }
        return head.description + " :- " + body.map{ String($0) }.joinWithSeparator(", ") + "."
    }
}

// Bindings used in a `Clause` are expected to remain local to a clause. As such, initializers that properly scope needed bindings
// are provided for convenience and correctness.
extension Clause {
    public init(build: () -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build()
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: Binding<Term<Atom>> -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding())
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>) -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: (Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>, Binding<Term<Atom>>) -> (rule: Term<Atom>, conditions: [Term<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding(), Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }
}

extension Clause: ContextCopyable {
    public static func copy(this: Clause, withContext context: CopyContext) -> Clause {
        return Clause(head: Term.copy(this.head, withContext: context), body: this.body.map{ Term.copy($0, withContext: context) })
    }
}
