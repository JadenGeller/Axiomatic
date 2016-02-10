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
    func testUnifyPredicate() {
        let a = Binding<Term<Int>>()
        let b = Binding<Term<Int>>()
        // 100(a, 0, 1).
        let p1 = Term(name: 100, arguments: [.Variable(a), .Literal(Term(atom: 0)), .Literal(Term(atom: 1))])
        // 100(-1, 0, b).
        let p2 = Term(name: 100, arguments: [.Literal(Term(atom: -1)), .Literal(Term(atom: 0)), .Variable(b)])
                
        try! Term.unify(p1, p2)
        
        XCTAssertEqual(-1, a.value?.name)
        XCTAssertEqual(1, b.value?.name)
    }
    
    func testUnifyPredicateNested() {
        let a = Binding<Term<Int>>()
        // 100(10(1)).
        let p1 = Term(name: 100, arguments: [.Literal(Term(name: 10, arguments: [.Literal(Term(atom: 1))]))])
        // 100(10(a)).
        let p2 = Term(name: 100, arguments: [.Literal(Term(name: 10, arguments: [.Variable(a)]))])
        
        try! Term.unify(p1, p2)
        
        XCTAssertEqual(1, a.value?.name)
    }
    
    func testUnifyPredicateNestedVariable() {
        let a = Binding<Term<Int>>()
        let b = Binding<Term<Int>>()
        let p1 = Term(name: 100, arguments: [.Literal(Term(name: 10, arguments: [.Variable(a)]))])
        let p2 = Term(name: 100, arguments: [.Literal(Term(name: 10, arguments: [.Variable(b)]))])
        
        try! Term.unify(p1, p2)
        
        b.value = Term(atom: 100)
        XCTAssertEqual(100, a.value?.name)
    }
    
    func testUnifyPredicateMismatchName() {
        let p1 = Term(name: 100, arguments: [.Literal(Term(atom: 10))])
        let p2 = Term(name: 101, arguments: [.Literal(Term(atom: 10))])
        
        XCTAssertNil(try? Term.unify(p1, p2))
    }
    
    func testUnifyPredicateMismatchArity() {
        let p1 = Term(name: 100, arguments: [.Literal(Term(atom: 10))])
        let p2 = Term(name: 100, arguments: [.Literal(Term(atom: 10)), .Literal(Term(atom: 10))])
        
        XCTAssertNil(try? Term.unify(p1, p2))
    }
    
    func testCopy() {
        var a = Term<Int>(name: 100, arguments: [.Variable(Binding())])
        var b = Term<Int>(name: 100, arguments: [.Variable(Binding())])
        try! Term.unify(a, b)

        let context = CopyContext()
        var aa = Term.copy(a, withContext: context)
        var bb = Term.copy(b, withContext: context)
        
        try! Term.unify(a, Term<Int>(name: 100, arguments: [.Literal(Term(atom: 5))]))
        XCTAssertEqual(5, a.arguments[0].value?.name)
        XCTAssertEqual(5, b.arguments[0].value?.name)
        XCTAssertEqual(nil, aa.arguments[0].value?.name)
        XCTAssertEqual(nil, bb.arguments[0].value?.name)

        try! Term.unify(aa, Term<Int>(name: 100, arguments: [.Literal(Term(atom: -5))]))
        XCTAssertEqual(5, a.arguments[0].value?.name)
        XCTAssertEqual(5, b.arguments[0].value?.name)
        XCTAssertEqual(-5, aa.arguments[0].value?.name)
        XCTAssertEqual(-5, bb.arguments[0].value?.name)
    }
}
