//
//  Utility.swift
//  Axiomatic
//
//  Created by Jaden Geller on 1/19/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

extension SequenceType {
    internal func groupBy<Group: Hashable>(group: Generator.Element -> Group) -> [Group : [Generator.Element]] {
        var result: [Group : [Generator.Element]] = [:]
        forEach { element in
            result[group(element)] = (result[group(element)] ?? []) + [element]
        }
        return result
    }
}