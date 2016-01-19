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
        try! system.satisfy(Predicate(name: "test", arguments: [
            .Variable(T), .Constant(Predicate(atom: "1")), .Variable(V)
        ]))
        XCTAssertEqual("b", T.value?.name)
        XCTAssertEqual("y", V.value?.name)
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
        try! system.satisfy(Predicate(name: "test", arguments: [
            .Variable(T), .Constant(Predicate(atom: "1")), .Variable(V)
            ]))
        XCTAssertEqual("a", T.value?.name)
        XCTAssertEqual("y", V.value?.name)
    }
}
