//
//  ClauseTests.swift
//  ClauseTests
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Axiomatic
@testable import Gluey

class ClauseTests: XCTestCase {
    func testCopy() {
        let a = Clause { binding in (
            rule: Predicate<Int>(name: 100, arguments: [.Variable(binding)]),
            conditions: [Predicate<Int>(name: 200, arguments: [.Variable(binding)])]
        )}

        let context = CopyContext()
        let b = Clause.copy(a, withContext: context)
        
        guard case let Value.Variable(bindingA) = b.head.arguments.first! else { fatalError() }
        guard case let Value.Variable(bindingB) = b.body.first!.arguments.first! else { fatalError() }
        XCTAssertTrue(bindingA.glue === bindingB.glue)
    }
    
    func testNestedCopy() {
        let a = Clause { binding in (
            rule: Predicate<Int>(name: 100, arguments: [.Variable(binding)]),
            conditions: [Predicate<Int>(name: 200, arguments: [
                    .Constant(Predicate(name: 300, arguments: [.Variable(binding)]))
                ])]
            )}
        
        let context = CopyContext()
        let b = Clause.copy(a, withContext: context)
        
        guard case let Value.Variable(bindingA) = b.head.arguments.first! else { fatalError() }
        guard case let Value.Variable(bindingB) = b.body.first!.arguments.first!.value!.arguments.first! else { fatalError() }
        XCTAssertTrue(bindingA.glue === bindingB.glue)
    }
}
