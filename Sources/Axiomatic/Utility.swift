//
//  Utility.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/19/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

extension Sequence {
    internal func groupBy<Group: Hashable>(group: (Element) -> Group) -> [Group : [Element]] {
        var result: [Group : [Element]] = [:]
        forEach { element in
            result[group(element)] = (result[group(element)] ?? []) + [element]
        }
        return result
    }
}
