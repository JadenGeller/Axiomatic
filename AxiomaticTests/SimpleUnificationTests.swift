//
//  UnityTests.swift
//  UnityTests
//
//  Created by Jaden Geller on 11/25/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Axiomatic

class SimpleUnificationTests: XCTestCase {
    
    func testUnifyVariableValue() {
        let a = Binding<Int>()
        try! Unifiable.unify(.Variable(a), .Literal(10))
        XCTAssertEqual(10, a.value)
    }
    
    func testUnifyVariableVariableValue() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        try! Unifiable.unify(.Variable(a), .Variable(b))
        try! Unifiable.unify(.Variable(a), .Literal(10))
        XCTAssertEqual(10, b.value)
    }
    
    func testUnifyVariableValueVariable() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        try! Unifiable.unify(.Variable(a), .Literal(10))
        try! Unifiable.unify(.Variable(a), .Variable(b))
        XCTAssertEqual(10, b.value)
    }
    
    func testUnifyVariableValueFailure() {
        let a = Binding<Int>()
        try! Unifiable.unify(.Variable(a), .Literal(10))
        guard (try? Unifiable.unify(.Variable(a), .Literal(-10))) == nil else { return XCTFail() }
    }
    
    func testUnifyVariableValueVariableValueFailure() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        try! Unifiable.unify(.Variable(a), .Literal(10))
        try! Unifiable.unify(.Variable(b), .Literal(-10))
        guard (try? Unifiable.unify(.Variable(a), .Variable(b))) == nil else { return XCTFail() }
    }
    
    func testUnifyVariableValueVariableValue() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        try! Unifiable.unify(.Variable(a), .Literal(10))
        try! Unifiable.unify(.Variable(b), .Literal(10))
        guard (try? Unifiable.unify(.Variable(a), .Variable(b))) != nil else { return XCTFail() }
        XCTAssert(a.value == 10)
        XCTAssert(b.value == 10)
    }
    
    func testRevertUnification() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        
        try! Unifiable.unify(.Variable(a), .Literal(10))
        
        let snapshotA = a.snapshotx(), snapshotB = b.snapshotx()
        do {
            try Unifiable.unify(.Variable(b), .Literal(-10))
            try Unifiable.unify(.Variable(a), .Variable(b))
            XCTFail()
        } catch {
            a.revert(toSnapshot: snapshotA)
            b.revert(toSnapshot: snapshotB)
            
            XCTAssert(b.value == nil)
        }
    }
}
