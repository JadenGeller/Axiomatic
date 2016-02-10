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
            Clause(fact: Term(name: "jaden", arguments: [.Literal(Term(atom: "cool"))])),
            // swift(awesome).
            Clause(fact: Term(name: "swift", arguments: [.Literal(Term(atom: "awesome"))]))
        ])
        var count = 0
        try! system.enumerateMatches(Term(name: "swift", arguments: [.Literal(Term(atom: "awesome"))])) {
            count += 1
        }
        XCTAssertEqual(1, count)
    }
    
    func testFailure() {
        let system = System(clauses: [
            // jaden(cool).
            Clause(fact: Term(name: "jaden", arguments: [.Literal(Term(atom: "cool"))])),
            // swift(awesome).
            Clause(fact: Term(name: "swift", arguments: [.Literal(Term(atom: "awesome"))]))
            ])
        var count = 0
        // swift(uncool).
        try! system.enumerateMatches(Term(name: "swift", arguments: [.Literal(Term(atom: "uncool"))])) {
            count += 1
        }
        XCTAssertEqual(0, count)
    }
    
    func testSimple() {
        let system = System(clauses: [
            // test(a, 0, x).
            Clause(fact: Term(name: "test", arguments: [
                .Literal(Term(atom: "a")), .Literal(Term(atom: "0")), .Literal(Term(atom: "x"))
            ])),
            // test(b, 1, y).
            Clause(fact: Term(name: "test", arguments: [
                .Literal(Term(atom: "b")), .Literal(Term(atom: "1")), .Literal(Term(atom: "y"))
            ]))
        ])
        
        let T = Binding<Term<String>>()
        let V = Binding<Term<String>>()
        // ? test(T, 1, V).
        try! system.enumerateMatches(Term(name: "test", arguments: [
            .Variable(T), .Literal(Term(atom: "1")), .Variable(V)
        ])) {
            XCTAssertEqual("b", T.value?.name)
            XCTAssertEqual("y", V.value?.name)
        }
    }
    
    func testSimpleBacktracking() {
        let system = System(clauses: [
            // test(a, 0, x).
            Clause(fact: Term(name: "test", arguments: [
                .Literal(Term(atom: "a")), .Literal(Term(atom: "0")), .Literal(Term(atom: "x"))
                ])),
            // test(a, 1, y).
            Clause(fact: Term(name: "test", arguments: [
                .Literal(Term(atom: "a")), .Literal(Term(atom: "1")), .Literal(Term(atom: "y"))
                ]))
            ])
        
        let T = Binding<Term<String>>()
        let V = Binding<Term<String>>()
        // ? test(T, 1, V).
        try! system.enumerateMatches(Term(name: "test", arguments: [
            .Variable(T), .Literal(Term(atom: "1")), .Variable(V)
        ])) {
            XCTAssertEqual("a", T.value?.name)
            XCTAssertEqual("y", V.value?.name)       
        }
    }
    
    func testRule() {
        let system = System(clauses: [
            // male(jaden).
            Clause(fact: Term(name: "male", arguments: [.Literal(Term(atom: "jaden"))])),
            // male(matt).
            Clause(fact: Term(name: "male", arguments: [.Literal(Term(atom: "matt"))])),
            // female(tuesday).
            Clause(fact: Term(name: "female", arguments: [.Literal(Term(atom: "tuesday"))])),
            // female(kiley).
            Clause(fact: Term(name: "female", arguments: [.Literal(Term(atom: "kiley"))])),
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
                [.Literal(Term(atom: "tuesday")), .Literal(Term(atom: "jaden"))])),
            // parent(matt, jaden).
            Clause(fact: Term(name: "parent", arguments:
                [.Literal(Term(atom: "matt")), .Literal(Term(atom: "jaden"))])),
            // parent(matt, kiley).
            Clause(fact: Term(name: "parent", arguments:
                [.Literal(Term(atom: "matt")), .Literal(Term(atom: "kiley"))])),
            // parent(tuesday, kiley).
            Clause(fact: Term(name: "parent", arguments:
                [.Literal(Term(atom: "tuesday")), .Literal(Term(atom: "kiley"))]))
        ])
        
        var results: [String] = []
        let Child = Binding<Term<String>>()
        // father(matt, Child).
        try! system.enumerateMatches(Term(name: "father", arguments: [.Literal(Term(atom: "matt")), .Variable(Child)])) {
            results.append(Child.value!.name)
        }
        XCTAssertEqual(["jaden", "kiley"], results)
    }
    
    func testRecursive() {
        let system = System(clauses: [
            // test(x).
            Clause(fact: Term(name: "test", arguments: [.Literal(Term(atom: "x"))])),
            // test(test(A)) :- test(A).
            Clause{ A in (
                rule: Term(name: "test", arguments: [.Literal(Term(name: "test", arguments: [.Variable(A)]))]),
                requirements: [Term(name: "test", arguments: [.Variable(A)])]
            ) }
        ])
        let A = Binding<Term<String>>()
        var count = 0
        // test(test(test(test(A)))).
        _ = try? system.enumerateMatches(Term(name: "test", arguments: [.Literal(Term(name: "test", arguments: [.Literal(Term(name: "test", arguments: [.Literal(Term(name: "test", arguments: [.Variable(A)]))]))]))])) {
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
                .Literal(Term(atom: "square")),
                .Literal(Term(name: "function", arguments: [
                    .Literal(Term(atom: "Int")),
                    .Literal(Term(atom: "Int"))
                ]))
            ])),
            // sqrt :: Int -> Int
            Clause(fact: Term(name: "binding", arguments: [
                .Literal(Term(atom: "sqrt")),
                .Literal(Term(name: "function", arguments: [
                    .Literal(Term(atom: "Int")),
                    .Literal(Term(atom: "Int"))
                ]))
            ])),
            // compose = f -> g -> x -> f (g x)
            Clause { A, B, C in (
                fact: Term(name: "binding", arguments: [
                    .Literal(Term(atom: "compose")),
                    .Literal(Term(name: "function", arguments: [
                        .Literal(Term(name: "function", arguments: [.Variable(B), .Variable(C)])),
                        .Literal(Term(name: "function", arguments: [
                            .Literal(Term(name: "function", arguments: [.Variable(A), .Variable(B)])),
                            .Literal(Term(name: "function", arguments: [.Variable(A), .Variable(C)]))
                        ]))
                    ]))
                ])
            )},
            Clause { Sqrt, Square, Abs in (
                rule: Term(name: "binding", arguments: [.Literal(Term(atom: "abs")), .Variable(Abs)]),
                conditions: [
                    Term(name: "binding", arguments: [.Literal(Term(atom: "sqrt")), .Variable(Sqrt)]),
                    Term(name: "binding", arguments: [.Literal(Term(atom: "square")), .Variable(Square)]),
                    Term(name: "binding", arguments: [.Literal(Term(atom: "compose")), .Literal(Term(name: "function", arguments: [
                        .Variable(Sqrt), .Literal(Term(name: "function", arguments: [
                            .Variable(Square),
                            .Variable(Abs)
                        ]))
                    ]))])
                ])
            }
        ])
        
        let Abs = Binding<Term<String>>()
        var count = 0
        _ = try? system.enumerateMatches(Term(name: "binding", arguments: [.Literal(Term(atom: "abs")), .Variable(Abs)])) {
            count++
            XCTAssertEqual(Term(name: "function", arguments: [.Literal(Term(atom: "Int")), .Literal(Term(atom: "Int"))]), Abs.value)
        }
        XCTAssertEqual(1, count)
    }
}
