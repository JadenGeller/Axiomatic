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
            // jaden(cool).
            Clause(fact: Predicate(name: "jaden", arguments: [.Constant(Predicate(atom: "cool"))])),
            // swift(awesome).
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
            // jaden(cool).
            Clause(fact: Predicate(name: "jaden", arguments: [.Constant(Predicate(atom: "cool"))])),
            // swift(awesome).
            Clause(fact: Predicate(name: "swift", arguments: [.Constant(Predicate(atom: "awesome"))]))
            ])
        var count = 0
        // swift(uncool).
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
            // test(a, 1, y).
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
            // male(jaden).
            Clause(fact: Predicate(name: "male", arguments: [.Constant(Predicate(atom: "jaden"))])),
            // male(matt).
            Clause(fact: Predicate(name: "male", arguments: [.Constant(Predicate(atom: "matt"))])),
            // female(tuesday).
            Clause(fact: Predicate(name: "female", arguments: [.Constant(Predicate(atom: "tuesday"))])),
            // female(kiley).
            Clause(fact: Predicate(name: "female", arguments: [.Constant(Predicate(atom: "kiley"))])),
            // father(Parent, Child) :- male(Parent), parent(Parent, Child).
            Clause{ parent, child in (
                rule: Predicate(name: "father", arguments: [.Variable(parent), .Variable(child)]),
                requirements: [
                    Predicate(name: "male", arguments: [.Variable(parent)]),
                    Predicate(name: "parent", arguments: [.Variable(parent), .Variable(child)])
                ]
            ) },
            // parent(tuesday, jaden).
            Clause(fact: Predicate(name: "parent", arguments:
                [.Constant(Predicate(atom: "tuesday")), .Constant(Predicate(atom: "jaden"))])),
            // parent(matt, jaden).
            Clause(fact: Predicate(name: "parent", arguments:
                [.Constant(Predicate(atom: "matt")), .Constant(Predicate(atom: "jaden"))])),
            // parent(matt, kiley).
            Clause(fact: Predicate(name: "parent", arguments:
                [.Constant(Predicate(atom: "matt")), .Constant(Predicate(atom: "kiley"))])),
            // parent(tuesday, kiley).
            Clause(fact: Predicate(name: "parent", arguments:
                [.Constant(Predicate(atom: "tuesday")), .Constant(Predicate(atom: "kiley"))]))
        ])
        
        var results: [String] = []
        let Child = Binding<Predicate<String>>()
        // father(matt, Child).
        try! system.enumerateMatches(Predicate(name: "father", arguments: [.Constant(Predicate(atom: "matt")), .Variable(Child)])) {
            results.append(Child.value!.name)
        }
        XCTAssertEqual(["jaden", "kiley"], results)
    }
    
    func testRecursive() {
        let system = System(clauses: [
            // test(x).
            Clause(fact: Predicate(name: "test", arguments: [.Constant(Predicate(atom: "x"))])),
            // test(test(A)) :- test(A).
            Clause{ A in (
                rule: Predicate(name: "test", arguments: [.Constant(Predicate(name: "test", arguments: [.Variable(A)]))]),
                requirements: [Predicate(name: "test", arguments: [.Variable(A)])]
            ) }
        ])
        let A = Binding<Predicate<String>>()
        var count = 0
        // test(test(test(test(A)))).
        _ = try? system.enumerateMatches(Predicate(name: "test", arguments: [.Constant(Predicate(name: "test", arguments: [.Constant(Predicate(name: "test", arguments: [.Constant(Predicate(name: "test", arguments: [.Variable(A)]))]))]))])) {
            XCTAssertEqual("x", A.value?.name)
            count += 1
            throw NSError(domain: "I don't care", code: 0, userInfo: nil)
        }
        XCTAssertEqual(1, count)
    }
    
//    func testTypeSystem() {
//        let system = System(clauses: [
//            // square :: Int -> Int
//            Clause(fact: Predicate(name: "binding", arguments: [
//                .Constant(Predicate(atom: "square")),
//                .Constant(Predicate(name: "function", arguments: [
//                    .Constant(Predicate(atom: "Int")),
//                    .Constant(Predicate(atom: "Int"))
//                ]))
//            ])),
//            // sqrt :: Int -> Int
//            Clause(fact: Predicate(name: "binding", arguments: [
//                .Constant(Predicate(atom: "sqrt")),
//                .Constant(Predicate(name: "function", arguments: [
//                    .Constant(Predicate(atom: "Int")),
//                    .Constant(Predicate(atom: "Int"))
//                ]))
//            ])),
//            // count :: Array a -> Int
//            Clause(fact: Predicate(name: "binding", arguments: [
//                .Constant(Predicate(atom: "count")),
//                .Constant(Predicate(name: "function", arguments: [
//                    .Constant(Predicate(name: "Array", arguments: [.Variable(A)])),
//                    .Constant(Predicate(atom: "Int"))
//                ]))
//            ])),
//        ])
//    }
}









