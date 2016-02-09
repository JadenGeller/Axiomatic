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
            rule: Term<Int>(name: 100, arguments: [.Variable(binding)]),
            conditions: [Term<Int>(name: 200, arguments: [.Variable(binding)])]
        )}

        let context = CopyContext()
        let b = Clause.copy(a, withContext: context)
        
        guard case let Unifiable.Variable(bindingA) = b.head.arguments.first! else { fatalError() }
        guard case let Unifiable.Variable(bindingB) = b.body.first!.arguments.first! else { fatalError() }
        XCTAssertTrue(bindingA.glue === bindingB.glue)
    }
    
    func testNestedCopy() {
        let a = Clause { binding in (
            rule: Term<Int>(name: 100, arguments: [.Variable(binding)]),
            conditions: [Term<Int>(name: 200, arguments: [
                    .Constant(Term(name: 300, arguments: [.Variable(binding)]))
                ])]
            )}
        
        let context = CopyContext()
        let b = Clause.copy(a, withContext: context)
        
        guard case let Unifiable.Variable(bindingA) = b.head.arguments.first! else { fatalError() }
        guard case let Unifiable.Variable(bindingB) = b.body.first!.arguments.first!.value!.arguments.first! else { fatalError() }
        XCTAssertTrue(bindingA.glue === bindingB.glue)
    }
}
