//
//  UnityTests.swift
//  UnityTests
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Axiomatic

class NestedUnificationTests: XCTestCase {
    
    func testUnifyAtomConstant() {
        XCTAssertNotNil(try? Value<String, Int>.unify(
            .Atom(5),
            .Atom(5)
        ))
    }
    
    func testUnifyAtom() {
        let a = Binding<Value<String, Int>>()
        XCTAssertNotNil(try? Unifiable<Value<String, Int>>.unify(
            .Variable(a),
            .Literal(.Atom(5))
        ))
        XCTAssertEqual(.Atom(5), a.value)
    }
    
    func testUnifyNested() {
        let a = Binding<Value<String, Int>>()
        XCTAssertNotNil(try? Value<String, Int>.unify(
            .Relation(Predicate(functor: "test", arguments: [.Variable(a)])),
            .Relation(Predicate(functor: "test", arguments: [.Literal(.Atom(5))]))
        ))
        XCTAssertEqual(.Atom(5), a.value)
    }
    
    func testUnifyNestedConstant() {
        XCTAssertNotNil(try? Value<String, Int>.unify(
            .Relation(Predicate(functor: "test", arguments: [.Literal(.Atom(5))])),
            .Relation(Predicate(functor: "test", arguments: [.Literal(.Atom(5))]))
        ))
    }
    
    func testUnifyMismatchName() {
        XCTAssertNil(try? Value<String, Int>.unify(
            .Relation(Predicate(functor: "test", arguments: [.Literal(.Atom(5))])),
            .Relation(Predicate(functor: "otherTest", arguments: [.Literal(.Atom(5))]))
        ))
    }
    
    func testUnifyMismatchArity() {
        XCTAssertNil(try? Value<String, Int>.unify(
            .Relation(Predicate(functor: "test", arguments: [.Literal(.Atom(5))])),
            .Relation(Predicate(functor: "test", arguments: [.Literal(.Atom(5)), .Literal(.Atom(5))]))
        ))
    }
    
    func testUnifyNestedOuter() {
        let a = Binding<Value<String, Int>>()
        XCTAssertNotNil(try? Value<String, Int>.unify(
            .Relation(Predicate(functor: "test", arguments: [.Variable(a)])),
            .Relation(Predicate(functor: "test", arguments: [.Literal(.Atom(5))]))
            ))
        XCTAssertEqual(.Atom(5), a.value)
    }
    
    func testUnifyNestedOuterDouble() {
        let a = Binding<Value<String, Int>>(), b = Binding<Value<String, Int>>()
        XCTAssertNotNil(try? Value<String, Int>.unify(
            .Relation(Predicate(functor: "test", arguments: [.Variable(a), .Literal(.Atom(10))])),
            .Relation(Predicate(functor: "test", arguments: [.Literal(.Atom(5)), .Variable(b)]))
            ))
        XCTAssertEqual(.Atom(5), a.value)
        XCTAssertEqual(.Atom(10), b.value)
    }
}
