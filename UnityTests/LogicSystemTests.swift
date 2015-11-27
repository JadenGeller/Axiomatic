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
        try! system.query(Predicate(functor: "test", arguments: [.Variable(v1), .Literal(.Atom("1")), .Variable(v2)]))
        XCTAssertEqual(.Atom("b"), v1.value)
        XCTAssertEqual(.Atom("y"), v2.value)
    }
}
