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
        let a = Binding<Predicate<Int>>()
        let b = Binding<Predicate<Int>>()
        // 100(a, 0, 1).
        let p1 = Predicate(name: 100, arguments: [.Variable(a), .Constant(Predicate(atom: 0)), .Constant(Predicate(atom: 1))])
        // 100(-1, 0, b).
        let p2 = Predicate(name: 100, arguments: [.Constant(Predicate(atom: -1)), .Constant(Predicate(atom: 0)), .Variable(b)])
                
        try! Predicate.unify(p1, p2)
        
        XCTAssertEqual(-1, a.value?.name)
        XCTAssertEqual(1, b.value?.name)
    }
    
    func testUnifyPredicateNested() {
        let a = Binding<Predicate<Int>>()
        // 100(10(1)).
        let p1 = Predicate(name: 100, arguments: [.Constant(Predicate(name: 10, arguments: [.Constant(Predicate(atom: 1))]))])
        // 100(10(a)).
        let p2 = Predicate(name: 100, arguments: [.Constant(Predicate(name: 10, arguments: [.Variable(a)]))])
        
        try! Predicate.unify(p1, p2)
        
        XCTAssertEqual(1, a.value?.name)
    }
    
    func testUnifyPredicateNestedVariable() {
        let a = Binding<Predicate<Int>>()
        let b = Binding<Predicate<Int>>()
        let p1 = Predicate(name: 100, arguments: [.Constant(Predicate(name: 10, arguments: [.Variable(a)]))])
        let p2 = Predicate(name: 100, arguments: [.Constant(Predicate(name: 10, arguments: [.Variable(b)]))])
        
        try! Predicate.unify(p1, p2)
        
        b.value = Predicate(atom: 100)
        XCTAssertEqual(100, a.value?.name)
    }
    
    func testUnifyPredicateMismatchName() {
        let p1 = Predicate(name: 100, arguments: [.Constant(Predicate(atom: 10))])
        let p2 = Predicate(name: 101, arguments: [.Constant(Predicate(atom: 10))])
        
        XCTAssertNil(try? Predicate.unify(p1, p2))
    }
    
    func testUnifyPredicateMismatchArity() {
        let p1 = Predicate(name: 100, arguments: [.Constant(Predicate(atom: 10))])
        let p2 = Predicate(name: 100, arguments: [.Constant(Predicate(atom: 10)), .Constant(Predicate(atom: 10))])
        
        XCTAssertNil(try? Predicate.unify(p1, p2))
    }
    
    func testCopy() {
        var a = Predicate<Int>(name: 100, arguments: [.Variable(Binding())])
        var b = Predicate<Int>(name: 100, arguments: [.Variable(Binding())])
        try! Predicate.unify(a, b)

        let context = CopyContext()
        var aa = Predicate.copy(a, withContext: context)
        var bb = Predicate.copy(b, withContext: context)
        
        try! Predicate.unify(a, Predicate<Int>(name: 100, arguments: [.Constant(Predicate(atom: 5))]))
        XCTAssertEqual(5, a.arguments[0].value?.name)
        XCTAssertEqual(5, b.arguments[0].value?.name)
        XCTAssertEqual(nil, aa.arguments[0].value?.name)
        XCTAssertEqual(nil, bb.arguments[0].value?.name)

        try! Predicate.unify(aa, Predicate<Int>(name: 100, arguments: [.Constant(Predicate(atom: -5))]))
        XCTAssertEqual(5, a.arguments[0].value?.name)
        XCTAssertEqual(5, b.arguments[0].value?.name)
        XCTAssertEqual(-5, aa.arguments[0].value?.name)
        XCTAssertEqual(-5, bb.arguments[0].value?.name)
    }
}