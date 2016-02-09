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
            Clause(fact: Term(name: "jaden", arguments: [.Constant(Term(atom: "cool"))])),
            // swift(awesome).
            Clause(fact: Term(name: "swift", arguments: [.Constant(Term(atom: "awesome"))]))
        ])
        var count = 0
        try! system.enumerateMatches(Term(name: "swift", arguments: [.Constant(Term(atom: "awesome"))])) {
            count += 1
        }
        XCTAssertEqual(1, count)
    }
    
    func testFailure() {
        let system = System(clauses: [
            // jaden(cool).
            Clause(fact: Term(name: "jaden", arguments: [.Constant(Term(atom: "cool"))])),
            // swift(awesome).
            Clause(fact: Term(name: "swift", arguments: [.Constant(Term(atom: "awesome"))]))
            ])
        var count = 0
        // swift(uncool).
        try! system.enumerateMatches(Term(name: "swift", arguments: [.Constant(Term(atom: "uncool"))])) {
            count += 1
        }
        XCTAssertEqual(0, count)
    }
    
    func testSimple() {
        let system = System(clauses: [
            // test(a, 0, x).
            Clause(fact: Term(name: "test", arguments: [
                .Constant(Term(atom: "a")), .Constant(Term(atom: "0")), .Constant(Term(atom: "x"))
            ])),
            // test(b, 1, y).
            Clause(fact: Term(name: "test", arguments: [
                .Constant(Term(atom: "b")), .Constant(Term(atom: "1")), .Constant(Term(atom: "y"))
            ]))
        ])
        
        let T = Binding<Term<String>>()
        let V = Binding<Term<String>>()
        // ? test(T, 1, V).
        try! system.enumerateMatches(Term(name: "test", arguments: [
            .Variable(T), .Constant(Term(atom: "1")), .Variable(V)
        ])) {
            XCTAssertEqual("b", T.value?.name)
            XCTAssertEqual("y", V.value?.name)
        }
    }
    
    func testSimpleBacktracking() {
        let system = System(clauses: [
            // test(a, 0, x).
            Clause(fact: Term(name: "test", arguments: [
                .Constant(Term(atom: "a")), .Constant(Term(atom: "0")), .Constant(Term(atom: "x"))
                ])),
            // test(a, 1, y).
            Clause(fact: Term(name: "test", arguments: [
                .Constant(Term(atom: "a")), .Constant(Term(atom: "1")), .Constant(Term(atom: "y"))
                ]))
            ])
        
        let T = Binding<Term<String>>()
        let V = Binding<Term<String>>()
        // ? test(T, 1, V).
        try! system.enumerateMatches(Term(name: "test", arguments: [
            .Variable(T), .Constant(Term(atom: "1")), .Variable(V)
        ])) {
            XCTAssertEqual("a", T.value?.name)
            XCTAssertEqual("y", V.value?.name)       
        }
    }
    
    func testRule() {
        let system = System(clauses: [
            // male(jaden).
            Clause(fact: Term(name: "male", arguments: [.Constant(Term(atom: "jaden"))])),
            // male(matt).
            Clause(fact: Term(name: "male", arguments: [.Constant(Term(atom: "matt"))])),
            // female(tuesday).
            Clause(fact: Term(name: "female", arguments: [.Constant(Term(atom: "tuesday"))])),
            // female(kiley).
            Clause(fact: Term(name: "female", arguments: [.Constant(Term(atom: "kiley"))])),
            // father(Parent, Child) :- male(Parent), parent(Parent, Child).
            Clause{ parent, child in (
                rule: Term(name: "father", arguments: [.Variable(parent), .Variable(child)]),
                requirements: [
                    Term(name: "male", arguments: [.Variable(parent)]),
                    Term(name: "parent", arguments: [.Variable(parent), .Variable(child)])
                ]
            ) },
            // parent(tuesday, jaden).
            Clause(fact: Term(name: "parent", arguments:
                [.Constant(Term(atom: "tuesday")), .Constant(Term(atom: "jaden"))])),
            // parent(matt, jaden).
            Clause(fact: Term(name: "parent", arguments:
                [.Constant(Term(atom: "matt")), .Constant(Term(atom: "jaden"))])),
            // parent(matt, kiley).
            Clause(fact: Term(name: "parent", arguments:
                [.Constant(Term(atom: "matt")), .Constant(Term(atom: "kiley"))])),
            // parent(tuesday, kiley).
            Clause(fact: Term(name: "parent", arguments:
                [.Constant(Term(atom: "tuesday")), .Constant(Term(atom: "kiley"))]))
        ])
        
        var results: [String] = []
        let Child = Binding<Term<String>>()
        // father(matt, Child).
        try! system.enumerateMatches(Term(name: "father", arguments: [.Constant(Term(atom: "matt")), .Variable(Child)])) {
            results.append(Child.value!.name)
        }
        XCTAssertEqual(["jaden", "kiley"], results)
    }
    
    func testRecursive() {
        let system = System(clauses: [
            // test(x).
            Clause(fact: Term(name: "test", arguments: [.Constant(Term(atom: "x"))])),
            // test(test(A)) :- test(A).
            Clause{ A in (
                rule: Term(name: "test", arguments: [.Constant(Term(name: "test", arguments: [.Variable(A)]))]),
                requirements: [Term(name: "test", arguments: [.Variable(A)])]
            ) }
        ])
        let A = Binding<Term<String>>()
        var count = 0
        // test(test(test(test(A)))).
        _ = try? system.enumerateMatches(Term(name: "test", arguments: [.Constant(Term(name: "test", arguments: [.Constant(Term(name: "test", arguments: [.Constant(Term(name: "test", arguments: [.Variable(A)]))]))]))])) {
            XCTAssertEqual("x", A.value?.name)
            count += 1
            throw NSError(domain: "I don't care", code: 0, userInfo: nil)
        }
        XCTAssertEqual(1, count)
    }
    
    func testFunctionTypeUnifications() {
        let system = System(clauses: [
            // square :: Int -> Int
            Clause(fact: Term(name: "binding", arguments: [
                .Constant(Term(atom: "square")),
                .Constant(Term(name: "function", arguments: [
                    .Constant(Term(atom: "Int")),
                    .Constant(Term(atom: "Int"))
                ]))
            ])),
            // sqrt :: Int -> Int
            Clause(fact: Term(name: "binding", arguments: [
                .Constant(Term(atom: "sqrt")),
                .Constant(Term(name: "function", arguments: [
                    .Constant(Term(atom: "Int")),
                    .Constant(Term(atom: "Int"))
                ]))
            ])),
            // compose = f -> g -> x -> f (g x)
            Clause { A, B, C in (
                fact: Term(name: "binding", arguments: [
                    .Constant(Term(atom: "compose")),
                    .Constant(Term(name: "function", arguments: [
                        .Constant(Term(name: "function", arguments: [.Variable(B), .Variable(C)])),
                        .Constant(Term(name: "function", arguments: [
                            .Constant(Term(name: "function", arguments: [.Variable(A), .Variable(B)])),
                            .Constant(Term(name: "function", arguments: [.Variable(A), .Variable(C)]))
                        ]))
                    ]))
                ])
            )},
            Clause { Sqrt, Square, Abs in (
                rule: Term(name: "binding", arguments: [.Constant(Term(atom: "abs")), .Variable(Abs)]),
                conditions: [
                    Term(name: "binding", arguments: [.Constant(Term(atom: "sqrt")), .Variable(Sqrt)]),
                    Term(name: "binding", arguments: [.Constant(Term(atom: "square")), .Variable(Square)]),
                    Term(name: "binding", arguments: [.Constant(Term(atom: "compose")), .Constant(Term(name: "function", arguments: [
                        .Variable(Sqrt), .Constant(Term(name: "function", arguments: [
                            .Variable(Square),
                            .Variable(Abs)
                        ]))
                    ]))])
                ])
            }
        ])
        
        let Abs = Binding<Term<String>>()
        var count = 0
        _ = try? system.enumerateMatches(Term(name: "binding", arguments: [.Constant(Term(atom: "abs")), .Variable(Abs)])) {
            count++
            XCTAssertEqual(Term(name: "function", arguments: [.Constant(Term(atom: "Int")), .Constant(Term(atom: "Int"))]), Abs.value)
        }
        XCTAssertEqual(1, count)
    }
}









