//
//  PredicateTests.swift
//  PredicateTests
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Axiomatic
import Gluey

class PredicateTests: XCTestCase {
    func testUnifyPredicate() throws {
        let a = Binding<Term<Int>>()
        let b = Binding<Term<Int>>()
        // 100(a, 0, 1).
        let p1 = Term(name: 100, arguments: [.variable(a), .literal(Term(atom: 0)), .literal(Term(atom: 1))])
        // 100(-1, 0, b).
        let p2 = Term(name: 100, arguments: [.literal(Term(atom: -1)), .literal(Term(atom: 0)), .variable(b)])
                
        try? Term.unify(p1, p2)
        
        XCTAssertEqual(-1, a.value?.name)
        XCTAssertEqual(1, b.value?.name)
    }
    
    func testUnifyPredicateNested() throws {
        let a = Binding<Term<Int>>()
        // 100(10(1)).
        let p1 = Term(name: 100, arguments: [.literal(Term(name: 10, arguments: [.literal(Term(atom: 1))]))])
        // 100(10(a)).
        let p2 = Term(name: 100, arguments: [.literal(Term(name: 10, arguments: [.variable(a)]))])
        
        try Term.unify(p1, p2)
        
        XCTAssertEqual(1, a.value?.name)
    }
    
    func testUnifyPredicateNestedVariable() throws {
        let a = Binding<Term<Int>>()
        let b = Binding<Term<Int>>()
        let p1 = Term(name: 100, arguments: [.literal(Term(name: 10, arguments: [.variable(a)]))])
        let p2 = Term(name: 100, arguments: [.literal(Term(name: 10, arguments: [.variable(b)]))])
        
        try Term.unify(p1, p2)
        
        b.value = Term(atom: 100)
        XCTAssertEqual(100, a.value?.name)
    }
    
    func testUnifyPredicateMismatchName() {
        let p1 = Term(name: 100, arguments: [.literal(Term(atom: 10))])
        let p2 = Term(name: 101, arguments: [.literal(Term(atom: 10))])
        
        XCTAssertNil(try? Term.unify(p1, p2))
    }
    
    func testUnifyPredicateMismatchArity() {
        let p1 = Term(name: 100, arguments: [.literal(Term(atom: 10))])
        let p2 = Term(name: 100, arguments: [.literal(Term(atom: 10)), .literal(Term(atom: 10))])
        
        XCTAssertNil(try? Term.unify(p1, p2))
    }
    
    func testCopy() throws {
        var a = Term<Int>(name: 100, arguments: [.variable(Binding())])
        var b = Term<Int>(name: 100, arguments: [.variable(Binding())])
        try Term.unify(a, b)

        let context = CopyContext()
        var aa = Term.copy(a, withContext: context)
        var bb = Term.copy(b, withContext: context)
        
        try Term.unify(a, Term<Int>(name: 100, arguments: [.literal(Term(atom: 5))]))
        XCTAssertEqual(5, a.arguments[0].value?.name)
        XCTAssertEqual(5, b.arguments[0].value?.name)
        XCTAssertEqual(nil, aa.arguments[0].value?.name)
        XCTAssertEqual(nil, bb.arguments[0].value?.name)

        try Term.unify(aa, Term<Int>(name: 100, arguments: [.literal(Term(atom: -5))]))
        XCTAssertEqual(5, a.arguments[0].value?.name)
        XCTAssertEqual(5, b.arguments[0].value?.name)
        XCTAssertEqual(-5, aa.arguments[0].value?.name)
        XCTAssertEqual(-5, bb.arguments[0].value?.name)
    }
}
