//
//  SystemTests.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import XCTest
import Axiomatic

import Gluey

class SystemTests: XCTestCase {
    func testSuccess() {
        let system = System(clauses: [
            Clause(fact: Predicate(name: "jaden", arguments: [.Constant(Predicate(atom: "cool"))])),
            Clause(fact: Predicate(name: "swift", arguments: [.Constant(Predicate(atom: "awesome"))]))
        ])
        var count = 0
        try! system.enumerateMatches(Predicate(name: "swift", arguments: [.Constant(Predicate(atom: "awesome"))])) {
            count += 1
        }
        XCTAssertEqual(1, count)
    }
    
    func testFailure() {
        let system = System(clauses: [
            Clause(fact: Predicate(name: "jaden", arguments: [.Constant(Predicate(atom: "cool"))])),
            Clause(fact: Predicate(name: "swift", arguments: [.Constant(Predicate(atom: "awesome"))]))
            ])
        var count = 0
        try! system.enumerateMatches(Predicate(name: "swift", arguments: [.Constant(Predicate(atom: "uncool"))])) {
            count += 1
        }
        XCTAssertEqual(0, count)
    }
    
    func testSimple() {
        let system = System(clauses: [
            // test(a, 0, x).
            Clause(fact: Predicate(name: "test", arguments: [
                .Constant(Predicate(atom: "a")), .Constant(Predicate(atom: "0")), .Constant(Predicate(atom: "x"))
            ])),
            // test(b, 1, y).
            Clause(fact: Predicate(name: "test", arguments: [
                .Constant(Predicate(atom: "b")), .Constant(Predicate(atom: "1")), .Constant(Predicate(atom: "y"))
            ]))
        ])
        
        let T = Binding<Predicate<String>>()
        let V = Binding<Predicate<String>>()
        // ? test(T, 1, V).
        try! system.enumerateMatches(Predicate(name: "test", arguments: [
            .Variable(T), .Constant(Predicate(atom: "1")), .Variable(V)
        ])) {
            XCTAssertEqual("b", T.value?.name)
            XCTAssertEqual("y", V.value?.name)
        }
    }
    
    func testSimpleBacktracking() {
        let system = System(clauses: [
            // test(a, 0, x).
            Clause(fact: Predicate(name: "test", arguments: [
                .Constant(Predicate(atom: "a")), .Constant(Predicate(atom: "0")), .Constant(Predicate(atom: "x"))
                ])),
            // test(b, 1, y).
            Clause(fact: Predicate(name: "test", arguments: [
                .Constant(Predicate(atom: "a")), .Constant(Predicate(atom: "1")), .Constant(Predicate(atom: "y"))
                ]))
            ])
        
        let T = Binding<Predicate<String>>()
        let V = Binding<Predicate<String>>()
        // ? test(T, 1, V).
        try! system.enumerateMatches(Predicate(name: "test", arguments: [
            .Variable(T), .Constant(Predicate(atom: "1")), .Variable(V)
        ])) {
            XCTAssertEqual("a", T.value?.name)
            XCTAssertEqual("y", V.value?.name)       
        }
    }
    
    func testRule() {
        let system = System(clauses: [
            Clause(fact: Predicate(name: "male", arguments: [.Constant(Predicate(atom: "jaden"))])),
            Clause(fact: Predicate(name: "male", arguments: [.Constant(Predicate(atom: "matt"))])),
            Clause(fact: Predicate(name: "female", arguments: [.Constant(Predicate(atom: "tuesady"))])),
            Clause(fact: Predicate(name: "female", arguments: [.Constant(Predicate(atom: "kiley"))])),
            Clause{ PARENT, CHILD in (
                rule: Predicate(name: "father", arguments: [.Variable(PARENT), .Variable(CHILD)]),
                requirements: [
                    Predicate(name: "male", arguments: [.Variable(PARENT)]),
                    Predicate(name: "parent", arguments: [.Variable(PARENT), .Variable(CHILD)])
                ]
            ) },
            Clause(fact: Predicate(name: "parent", arguments:
                [.Constant(Predicate(atom: "tuesday")), .Constant(Predicate(atom: "jaden"))])),
            Clause(fact: Predicate(name: "parent", arguments:
                [.Constant(Predicate(atom: "matt")), .Constant(Predicate(atom: "jaden"))])),
            Clause(fact: Predicate(name: "parent", arguments:
                [.Constant(Predicate(atom: "matt")), .Constant(Predicate(atom: "kiley"))])),
            Clause(fact: Predicate(name: "parent", arguments:
                [.Constant(Predicate(atom: "tuesday")), .Constant(Predicate(atom: "kiley"))]))
        ])
        
        var results: [String] = []
        let CHILD = Binding<Predicate<String>>()
        try! system.enumerateMatches(Predicate(name: "father", arguments: [.Constant(Predicate(atom: "matt")), .Variable(CHILD)])) {
            results.append(CHILD.value!.name)
            print("MATCH: \(CHILD.value)")
            throw UnificationError("continue")
        }
        XCTAssertEqual(["jaden", "kiley"], results)
    }
    
    func testRecursive() {
        let system = System(clauses: [
            Clause(fact: Predicate(name: "test", arguments: [.Constant(Predicate(atom: "x"))])),
            Clause{ A in (
                rule: Predicate(name: "test", arguments: [.Constant(Predicate(name: "test", arguments: [.Variable(A)]))]),
                requirements: [Predicate(name: "test", arguments: [.Variable(A)])]
            ) }
        ])
        let A = Binding<Predicate<String>>()
        var count = 0
        try! system.enumerateMatches(Predicate(name: "test", arguments: [.Constant(Predicate(name: "test", arguments: [.Constant(Predicate(name: "test", arguments: [.Constant(Predicate(name: "test", arguments: [.Variable(A)]))]))]))])) {
            count += 1
        }
        XCTAssertEqual(1, count)
    }
}
