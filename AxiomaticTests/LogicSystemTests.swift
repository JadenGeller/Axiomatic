//
//  LogicSystemTests.swift
//  Axiomatic
//
//  Created by Jaden Geller on 11/26/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Axiomatic

class LogicSystemTests: XCTestCase {

    func testBacktracking() {
        let system = System(clauses: [
            .Fact(Predicate(functor: "test", arguments: [.Literal(.Atom("a")), .Literal(.Atom("0")), .Literal(.Atom("x"))])),
            .Fact(Predicate(functor: "test", arguments: [.Literal(.Atom("b")), .Literal(.Atom("1")), .Literal(.Atom("y"))]))
        ])
        
        let v1 = Binding<Value<String, String>>()
        let v2 = Binding<Value<String, String>>()
        try! system.unify([Predicate(functor: "test", arguments: [.Variable(v1), .Literal(.Atom("1")), .Variable(v2)])])
        XCTAssertEqual(.Atom("b"), v1.value)
        XCTAssertEqual(.Atom("y"), v2.value)
    }
    
    func testFather() {
        let system = System(clauses: [
            .Fact(Predicate(functor: "male", arguments: [.Literal(.Atom("jaden"))])),
            .Fact(Predicate(functor: "male", arguments: [.Literal(.Atom("matt"))])),
            {
                let parent = Binding<Value<String, String>>()
                let child = Binding<Value<String, String>>()
                return .Rule(Predicate(functor: "father", arguments: [.Variable(parent), .Variable(child)]), [
                    Predicate(functor: "male", arguments: [.Variable(parent)]),
                    Predicate(functor: "parent", arguments: [.Variable(parent), .Variable(child)])
                ])
            }(),
            .Fact(Predicate(functor: "parent", arguments: [.Literal(.Atom("tuesday")), .Literal(.Atom("jaden"))])),
            .Fact(Predicate(functor: "parent", arguments: [.Literal(.Atom("matt")), .Literal(.Atom("jaden"))])),
        ])
        
        let father = Binding<Value<String, String>>()
        try! system.unify([Predicate(functor: "father", arguments: [.Variable(father), .Literal(.Atom("jaden"))])])
        XCTAssertEqual(.Atom("matt"), father.value)
    }
    
    func testFlip() {
        let systemBuilder = { System(clauses: [
            .Fact(Predicate(functor: "blah", arguments: [.Literal(.Atom("hey"))])),
            .Fact(Predicate(functor: "bleh", arguments: [.Literal(.Atom("hi"))])),
            {
                let x = Binding<Value<String, String>>()
                let y = Binding<Value<String, String>>()
                return .Rule(Predicate(functor: "rule", arguments: [.Variable(x), .Variable(y)]), [
                    Predicate(functor: "blah", arguments: [.Variable(x)]),
                    Predicate(functor: "bleh", arguments: [.Variable(y)])
                ])
            }(),
            {
                let x = Binding<Value<String, String>>()
                let y = Binding<Value<String, String>>()
                return .Rule(Predicate(functor: "flip", arguments: [.Variable(x), .Variable(y)]), [
                    Predicate(functor: "rule", arguments: [.Variable(y), .Variable(x)])
                ])
            }()
        ]) }
        
        do {
            try systemBuilder().unify([Predicate(functor: "flip", arguments: [.Literal(.Atom("hi")), .Literal(.Atom("hey"))])])
            // Success!
        } catch {
            XCTFail()
        }
        
        do {
            try systemBuilder().unify([Predicate(functor: "flip", arguments: [.Literal(.Atom("hey")), .Literal(.Atom("hi"))])])
            XCTFail()
        } catch {
            // Success!
        }
    }
}
