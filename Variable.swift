//
//  Variable.swift
//  Unity
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public class Binding<Value: Equatable> {
    private let value: Value?
    private var variables: Set<Variable<Value>> = []
    
    private init(value: Value? = nil) {
        self.value = value
    }
    
    private static func merge(bindings: [Binding]) throws -> Binding {
        
        // If binding values conflict, throw unification error.
        // Otherwise, set the value of the merged binding.
        let merged = try Binding(value: bindings.map{ $0.value }.reduce(nil) {
            if let a = $0, b = $1 where a != b {
                throw UnificationError("Cannot unify variables bound to different values.")
            }
            return $0 ?? $1
            })
        
        // Update each variable to use this binding.
        bindings.flatMap{ $0.variables }.forEach{
            $0.binding = merged
        }
        
        return merged
    }
}

public class Variable<Value: Equatable> {
    private var binding: Binding<Value> {
        willSet {
            binding.variables.remove(self)
        }
        didSet {
            binding.variables.insert(self)
        }
    }
    
    public func snapshot() -> Binding<Value> {
        return binding
    }
    public func revert(toSnapshot snapshot: Binding<Value>) {
        self.binding = snapshot
    }
    
    public init() {
        binding = Binding()
        binding.variables.insert(self)
    }
    
    public var value: Value? {
        return binding.value
    }
    
    internal static func bind(variables: [Variable]) throws {
        try Binding.merge(variables.map { $0.binding })
    }
    
    internal func resolve(literalValue: Value) throws {
        if value == nil {
            try Binding.merge([binding, Binding(value: literalValue)])
        }
        else if value != literalValue {
            throw UnificationError("Cannot unify literal to a variable bound to a different value.")
        }
    }
}

extension Variable: Hashable {
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}
public func ==<Value>(lhs: Variable<Value>, rhs: Variable<Value>) -> Bool {
    return lhs === rhs
}
