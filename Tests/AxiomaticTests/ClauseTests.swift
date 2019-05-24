//
//  ClauseTests.swift
//  ClauseTests
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

@testable import Axiomatic
@testable import Gluey
import XCTest

class ClauseTests: XCTestCase {
    func testCopy() {
        let a = Clause { binding in (
            rule: Term<Int>(name: 100, arguments: [.variable(binding)]),
            conditions: [Term<Int>(name: 200, arguments: [.variable(binding)])]
        ) }

        let context = CopyContext()
        let b = Clause.copy(a, withContext: context)

        guard case let Unifiable.variable(bindingA) = b.head.arguments.first! else { fatalError() }
        guard case let Unifiable.variable(bindingB) = b.body.first!.arguments.first! else { fatalError() }
        XCTAssertTrue(bindingA.glue === bindingB.glue)
    }

    func testNestedCopy() {
        let a = Clause { binding in (
            rule: Term<Int>(name: 100, arguments: [.variable(binding)]),
            conditions: [Term<Int>(name: 200, arguments: [
                .literal(Term(name: 300, arguments: [.variable(binding)])),
            ])]
        ) }

        let context = CopyContext()
        let b = Clause.copy(a, withContext: context)

        guard case let Unifiable.variable(bindingA) = b.head.arguments.first! else { fatalError() }
        guard case let Unifiable.variable(bindingB) = b.body.first!.arguments.first!.value!.arguments.first! else { fatalError() }
        XCTAssertTrue(bindingA.glue === bindingB.glue)
    }
}
