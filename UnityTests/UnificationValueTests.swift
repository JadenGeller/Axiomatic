//
//  UnityTests.swift
//  UnityTests
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Unity

class UnificationValueTests: XCTestCase {
    
    func testUnifyVariableValue() {
        let a = Variable<Int>()
        try! UnificationValue.unify(.Variable(a), .Literal(10))
        XCTAssertEqual(10, a.value)
    }
    
    func testUnifyVariableVariableValue() {
        let a = Variable<Int>()
        let b = Variable<Int>()
        try! UnificationValue.unify(.Variable(a), .Variable(b))
        try! UnificationValue.unify(.Variable(a), .Literal(10))
        XCTAssertEqual(10, b.value)
    }
    
    func testUnifyVariableValueVariable() {
        let a = Variable<Int>()
        let b = Variable<Int>()
        try! UnificationValue.unify(.Variable(a), .Literal(10))
        try! UnificationValue.unify(.Variable(a), .Variable(b))
        XCTAssertEqual(10, b.value)
    }
    
    func testUnifyVariableValueFailure() {
        let a = Variable<Int>()
        try! UnificationValue.unify(.Variable(a), .Literal(10))
        guard (try? UnificationValue.unify(.Variable(a), .Literal(-10))) == nil else { return XCTFail() }
    }
    
    func testUnifyVariableValueVariableValueFailure() {
        let a = Variable<Int>()
        let b = Variable<Int>()
        try! UnificationValue.unify(.Variable(a), .Literal(10))
        try! UnificationValue.unify(.Variable(b), .Literal(-10))
        guard (try? UnificationValue.unify(.Variable(a), .Variable(b))) == nil else { return XCTFail() }
    }
    
    func testUnifyVariableValueVariableValue() {
        let a = Variable<Int>()
        let b = Variable<Int>()
        try! UnificationValue.unify(.Variable(a), .Literal(10))
        try! UnificationValue.unify(.Variable(b), .Literal(10))
        guard (try? UnificationValue.unify(.Variable(a), .Variable(b))) != nil else { return XCTFail() }
        XCTAssert(a.value == 10)
        XCTAssert(b.value == 10)
    }
    
    func testRevertUnification() {
        let a = Variable<Int>()
        let b = Variable<Int>()
        
        try! UnificationValue.unify(.Variable(a), .Literal(10))
        
        let snapshotA = a.snapshot(), snapshotB = b.snapshot()
        do {
            try UnificationValue.unify(.Variable(b), .Literal(-10))
            try UnificationValue.unify(.Variable(a), .Variable(b))
            XCTFail()
        } catch {
            a.revert(toSnapshot: snapshotA)
            b.revert(toSnapshot: snapshotB)
            
            XCTAssert(b.value == nil)
        }
    }
}
