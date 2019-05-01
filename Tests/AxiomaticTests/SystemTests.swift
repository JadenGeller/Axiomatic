//
//  SystemTests.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Axiomatic
import XCTest

import Gluey

class SystemTests: XCTestCase {
    func testSuccess() throws {
        let system = System(clauses: [
            // jaden(cool).
            Clause(fact: Term(name: "jaden", arguments: [.literal(Term(atom: "cool"))])),
            // swift(awesome).
            Clause(fact: Term(name: "swift", arguments: [.literal(Term(atom: "awesome"))])),
        ])
        var count = 0
        try system.enumerateMatches(Term(name: "swift", arguments: [.literal(Term(atom: "awesome"))])) {
            count += 1
        }
        XCTAssertEqual(1, count)
    }

    func testFailure() throws {
        let system = System(clauses: [
            // jaden(cool).
            Clause(fact: Term(name: "jaden", arguments: [.literal(Term(atom: "cool"))])),
            // swift(awesome).
            Clause(fact: Term(name: "swift", arguments: [.literal(Term(atom: "awesome"))])),
        ])
        var count = 0
        // swift(uncool).
        XCTAssertThrowsError(
            try system.enumerateMatches(Term(name: "swift", arguments: [.literal(Term(atom: "uncool"))])) {
                count += 1
            }
        )
    }

    func testSimple() throws {
        let system = System(clauses: [
            // test(a, 0, x).
            Clause(fact: Term(name: "test", arguments: [
                .literal(Term(atom: "a")), .literal(Term(atom: "0")), .literal(Term(atom: "x")),
            ])),
            // test(b, 1, y).
            Clause(fact: Term(name: "test", arguments: [
                .literal(Term(atom: "b")), .literal(Term(atom: "1")), .literal(Term(atom: "y")),
            ])),
        ])

        let T = Binding<Term<String>>()
        let V = Binding<Term<String>>()
        // ? test(T, 1, V).
        try system.enumerateMatches(Term(name: "test", arguments: [
            .variable(T), .literal(Term(atom: "1")), .variable(V),
        ])) {
            XCTAssertEqual("b", T.value?.name)
            XCTAssertEqual("y", V.value?.name)
        }
    }

    func testSimpleBacktracking() throws {
        let system = System(clauses: [
            // test(a, 0, x).
            Clause(fact: Term(name: "test", arguments: [
                .literal(Term(atom: "a")), .literal(Term(atom: "0")), .literal(Term(atom: "x")),
            ])),
            // test(a, 1, y).
            Clause(fact: Term(name: "test", arguments: [
                .literal(Term(atom: "a")), .literal(Term(atom: "1")), .literal(Term(atom: "y")),
            ])),
        ])

        let T = Binding<Term<String>>()
        let V = Binding<Term<String>>()
        // ? test(T, 1, V).
        try system.enumerateMatches(Term(name: "test", arguments: [
            .variable(T), .literal(Term(atom: "1")), .variable(V),
        ])) {
            XCTAssertEqual("a", T.value?.name)
            XCTAssertEqual("y", V.value?.name)
        }
    }

    func testRule() throws {
        let system = System(clauses: [
            // male(jaden).
            Clause(fact: Term(name: "male", arguments: [.literal(Term(atom: "jaden"))])),
            // male(matt).
            Clause(fact: Term(name: "male", arguments: [.literal(Term(atom: "matt"))])),
            // female(tuesday).
            Clause(fact: Term(name: "female", arguments: [.literal(Term(atom: "tuesday"))])),
            // female(kiley).
            Clause(fact: Term(name: "female", arguments: [.literal(Term(atom: "kiley"))])),
            // father(Parent, Child) :- male(Parent), parent(Parent, Child).
            Clause { parent, child in (
                rule: Term(name: "father", arguments: [.variable(parent), .variable(child)]),
                conditions: [
                    Term(name: "male", arguments: [.variable(parent)]),
                    Term(name: "parent", arguments: [.variable(parent), .variable(child)]),
                ]
            ) },
            // parent(tuesday, jaden).
            Clause(fact: Term(name: "parent", arguments:
                [.literal(Term(atom: "tuesday")), .literal(Term(atom: "jaden"))])),
            // parent(matt, jaden).
            Clause(fact: Term(name: "parent", arguments:
                [.literal(Term(atom: "matt")), .literal(Term(atom: "jaden"))])),
            // parent(matt, kiley).
            Clause(fact: Term(name: "parent", arguments:
                [.literal(Term(atom: "matt")), .literal(Term(atom: "kiley"))])),
            // parent(tuesday, kiley).
            Clause(fact: Term(name: "parent", arguments:
                [.literal(Term(atom: "tuesday")), .literal(Term(atom: "kiley"))])),
        ])

        var results: [String] = []
        let Child = Binding<Term<String>>()
        // father(matt, Child).
        try system.enumerateMatches(Term(name: "father", arguments: [.literal(Term(atom: "matt")), .variable(Child)])) {
            guard let name = Child.value?.name else { return }
            Child.value = nil
            results.append(name)
        }
        XCTAssertEqual(["jaden", "kiley"], results)
    }

    func testRule2() throws {
        let system = System(clauses: [
            // parent(matt, jaden).
            Clause(fact: Term(name: "parent", arguments: [
                .literal(Term(atom: "Matt")),
                .literal(Term(atom: "Jaden")),
            ])),
            // parent(tuesday, jaden).
            Clause(fact: Term(name: "parent", arguments: [
                .literal(Term(atom: "Tuesday")),
                .literal(Term(atom: "Jaden")),
            ])),
            // parent(debbie, matt).
            Clause(fact: Term(name: "parent", arguments: [
                .literal(Term(atom: "Debbie")),
                .literal(Term(atom: "Matt")),
            ])),
            // parent(dennis, matt).
            Clause(fact: Term(name: "parent", arguments: [
                .literal(Term(atom: "Dennis")),
                .literal(Term(atom: "Matt")),
            ])),
            // parent(liz, tuesday).
            Clause(fact: Term(name: "parent", arguments: [
                .literal(Term(atom: "Liz")),
                .literal(Term(atom: "Tuesday")),
            ])),
            // parent(mike, tuesday).
            Clause(fact: Term(name: "parent", arguments: [
                .literal(Term(atom: "Mike")),
                .literal(Term(atom: "Tuesday")),
            ])),
            // grandparent(A, B) :- parent(A, X), parent(X, B).
            Clause { A, B, X in (
                rule: Term(name: "grandparent", arguments: [.variable(A), .variable(B)]),
                conditions: [
                    Term(name: "parent", arguments: [.variable(A), .variable(X)]),
                    Term(name: "parent", arguments: [.variable(X), .variable(B)]),
                ]
            ) },
        ])

        var results: [String] = []
        let G = Binding<Term<String>>()
        // grandparent(G, jaden).
        try system.enumerateMatches(Term(name: "grandparent", arguments: [.variable(G), .literal(Term(atom: "Jaden"))])) {
            guard let name = G.value?.name else { return }
            results.append(name)
        }
        XCTAssertEqual(["Debbie", "Dennis", "Liz", "Mike"], results)
    }

    func testRecursive() throws {
        let system = System(clauses: [
            // test(x).
            Clause(fact: Term(name: "test", arguments: [.literal(Term(atom: "x"))])),
            // test(test(A)) :- test(A).
            Clause { A in (
                rule: Term(name: "test", arguments: [.literal(Term(name: "test", arguments: [.variable(A)]))]),
                conditions: [Term(name: "test", arguments: [.variable(A)])]
            ) },
        ])
        let A = Binding<Term<String>>()
        var count = 0
        // test(test(test(test(A)))).
        try system.enumerateMatches(Term(name: "test", arguments: [.literal(Term(name: "test", arguments: [.literal(Term(name: "test", arguments: [.literal(Term(name: "test", arguments: [.variable(A)]))]))]))])) {
            XCTAssertEqual("x", A.value?.name)
            count += 1
        }
        XCTAssertEqual(1, count)
    }

    func testFunctionTypeUnifications() throws {
        let system = System(clauses: [
            // square :: Int -> Int
            Clause(fact: Term(name: "binding", arguments: [
                .literal(Term(atom: "square")),
                .literal(Term(name: "function", arguments: [
                    .literal(Term(atom: "Int")),
                    .literal(Term(atom: "Int")),
                ])),
            ])),
            // sqrt :: Int -> Int
            Clause(fact: Term(name: "binding", arguments: [
                .literal(Term(atom: "sqrt")),
                .literal(Term(name: "function", arguments: [
                    .literal(Term(atom: "Int")),
                    .literal(Term(atom: "Int")),
                ])),
            ])),
            // compose = f -> g -> x -> f (g x)
            Clause { A, B, C in
                Term(name: "binding", arguments: [
                    .literal(Term(atom: "compose")),
                    .literal(Term(name: "function", arguments: [
                        .literal(Term(name: "function", arguments: [.variable(B), .variable(C)])),
                        .literal(Term(name: "function", arguments: [
                            .literal(Term(name: "function", arguments: [.variable(A), .variable(B)])),
                            .literal(Term(name: "function", arguments: [.variable(A), .variable(C)])),
                        ])),
                    ])),
                ])
            },
            Clause { Sqrt, Square, Abs in (
                rule: Term(name: "binding", arguments: [.literal(Term(atom: "abs")), .variable(Abs)]),
                conditions: [
                    Term(name: "binding", arguments: [.literal(Term(atom: "sqrt")), .variable(Sqrt)]),
                    Term(name: "binding", arguments: [.literal(Term(atom: "square")), .variable(Square)]),
                    Term(name: "binding", arguments: [.literal(Term(atom: "compose")), .literal(Term(name: "function", arguments: [
                        .variable(Sqrt), .literal(Term(name: "function", arguments: [
                            .variable(Square),
                            .variable(Abs),
                        ])),
                    ]))]),
                ]
            )
            },
        ])

        let Abs = Binding<Term<String>>()
        var count = 0
        try system.enumerateMatches(Term(name: "binding", arguments: [.literal(Term(atom: "abs")), .variable(Abs)])) {
            count += 1
            XCTAssertEqual(Term(name: "function", arguments: [.literal(Term(atom: "Int")), .literal(Term(atom: "Int"))]), Abs.value)
        }
        XCTAssertEqual(1, count)
    }
}
