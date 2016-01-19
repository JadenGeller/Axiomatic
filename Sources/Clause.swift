//
//  Clause.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Gluey

public struct Clause<Atom: Hashable> {
    public var head: Predicate<Atom>
    public var body: [Predicate<Atom>]
    
    public init(fact: Predicate<Atom>) {
        self.head = fact
        self.body = []
    }
    
    public init(rule: Predicate<Atom>, conditions: [Predicate<Atom>]) {
        self.head = rule
        self.body = conditions
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
    public init(build: () -> (rule: Predicate<Atom>, conditions: [Predicate<Atom>])) {
        let (rule, conditions) = build()
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: Binding<Predicate<Atom>> -> (rule: Predicate<Atom>, conditions: [Predicate<Atom>])) {
        let (rule, conditions) = build(Binding())
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: (Binding<Predicate<Atom>>, Binding<Predicate<Atom>>) -> (rule: Predicate<Atom>, conditions: [Predicate<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: (Binding<Predicate<Atom>>, Binding<Predicate<Atom>>, Binding<Predicate<Atom>>) -> (rule: Predicate<Atom>, conditions: [Predicate<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: (Binding<Predicate<Atom>>, Binding<Predicate<Atom>>, Binding<Predicate<Atom>>, Binding<Predicate<Atom>>) -> (rule: Predicate<Atom>, conditions: [Predicate<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: (Binding<Predicate<Atom>>, Binding<Predicate<Atom>>, Binding<Predicate<Atom>>, Binding<Predicate<Atom>>, Binding<Predicate<Atom>>) -> (rule: Predicate<Atom>, conditions: [Predicate<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }
    
    public init(build: (Binding<Predicate<Atom>>, Binding<Predicate<Atom>>, Binding<Predicate<Atom>>, Binding<Predicate<Atom>>, Binding<Predicate<Atom>>, Binding<Predicate<Atom>>) -> (rule: Predicate<Atom>, conditions: [Predicate<Atom>])) {
        let (rule, conditions) = build(Binding(), Binding(), Binding(), Binding(), Binding(), Binding())
        self.init(rule: rule, conditions: conditions)
    }
}
