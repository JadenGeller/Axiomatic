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
        let p1 = Predicate(name: 100, arguments: [.Variable(a), .Constant(Predicate(atom: 0)), .Constant(Predicate(atom: 1))])
        let p2 = Predicate(name: 100, arguments: [.Constant(Predicate(atom: -1)), .Constant(Predicate(atom: 0)), .Variable(b)])
                
        try! Predicate.unify(p1, p2)
        
        XCTAssertEqual(-1, a.value?.name)
        XCTAssertEqual(1, b.value?.name)
    }
    
    func testUnifyPredicateNested() {
        let a = Binding<Predicate<Int>>()
        let p1 = Predicate(name: 100, arguments: [.Constant(Predicate(name: 10, arguments: [.Constant(Predicate(atom: 1))]))])
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
}
