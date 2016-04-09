//
//  CompositMapper.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/9/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

public struct CompositeMapper: Mapper {
    private let pipeline: [Transformer]

    init(pipeline: [Transformer]) {
        self.pipeline = pipeline
    }

    public func map(input: String) -> String {
        var intermediate = Intermediate(elements: [.Value(input)], depth: 0)

        for transformer in self.pipeline {
            switch transformer {
            case let splitter as Splitter:
                intermediate = intermediate.apply(splitter)
            case let mapper as Mapper:
                intermediate = intermediate.apply(mapper)
            case let reducer as Reducer:
                intermediate = intermediate.apply(reducer)
            default:
                break
            }
        }

        return intermediate.allValues.first!
    }
}