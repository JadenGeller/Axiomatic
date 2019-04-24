//
//  Functor.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

extension Term {
    /// The name-arity signature of `self`.
    public var functor: Functor<Atom> {
        return Functor(name: name, arity: arity)
    }
}

/// The name-arity signature of a `Term`. Defines a class of `Term`s that can potentially
/// be unified with each other.
public struct Functor<Atom: Hashable> {
    /// The name.
    public let name: Atom
    /// The number of arguments.
    public let arity: Int
}

extension Functor: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(arity)
    }
}

extension Functor: Equatable {
    public static func ==(lhs: Functor<Atom>, rhs: Functor<Atom>) -> Bool {
        return lhs.name == rhs.name && lhs.arity == rhs.arity
    }
}
