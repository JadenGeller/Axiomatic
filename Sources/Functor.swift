//
//  Functor.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

extension Predicate {
    public var functor: Functor<Atom> {
        return Functor(name: name, arity: arity)
    }
}

public struct Functor<Atom: Hashable> {
    public let name: Atom
    public let arity: Int
}

extension Functor: Hashable {
    public var hashValue: Int {
        return name.hashValue ^ arity.hashValue
    }
}

public func ==<Atom: Hashable>(lhs: Functor<Atom>, rhs: Functor<Atom>) -> Bool {
    return lhs.name == rhs.name && lhs.arity == rhs.arity
}
