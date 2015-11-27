//
//  Binding.swift
//  Unity
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

// Basic properties
public class Binding<Value: Equatable> {
    private var glue: Glue<Value> {
        willSet { glue.bindings.remove(self) }
        didSet  { glue.bindings.insert(self) }
    }
    
    public init() {
        glue = Glue()
        glue.bindings.insert(self)
    }
    
    public var value: Value? {
        return glue.value
    }
}

// Snapshotting
extension Binding {
    public typealias Snapshot = Glue<Value>
    
    public func snapshot() -> Snapshot {
        return glue
    }
    public func revert(toSnapshot snapshot: Snapshot) {
        self.glue = snapshot
    }
}

// Hashing
extension Binding: Hashable {
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}
public func ==<Value>(lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
    return lhs === rhs
}

// Unification
extension Binding {
    
    /// Binding together multiple bindings
    internal func bind(binding: Binding) throws {
        try Glue.merge([glue, binding.glue])
    }
    
    /// Bind to literal value
    internal func resolve(literalValue: Value) throws {
        if let value = value {
            guard value == literalValue else {
                throw UnificationError("Cannot unify literal to a value bound to a literal of a different value.")
            }
        } else {
            try Glue.merge([glue, Glue(value: literalValue)])
        }
    }
}

// Connecting bindings together
public class Glue<Value: Equatable> {
    private let value: Value?
    private var bindings: Set<Binding<Value>> = []
    
    private init(value: Value? = nil) {
        self.value = value
    }
    
    /// Merge multiple glue forming a new glue with shared bindings and a unique shared value
    private static func merge(glue: [Glue]) throws -> Glue {
        
        // If glue values conflict, throw unification error.
        // Otherwise, set the value of the merged glue.
        let merged = try Glue(value: glue.map{ $0.value }.reduce(nil) {
            if let a = $0, b = $1 where a != b {
                throw UnificationError("Cannot unify bindings that are bound to different literal values.")
            }
            return $0 ?? $1
            })
        
        // Update each binding to use this glue.
        glue.flatMap{ $0.bindings }.forEach{
            $0.glue = merged
        }
        
        return merged
    }
}
