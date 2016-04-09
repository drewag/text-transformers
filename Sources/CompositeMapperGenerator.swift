//
//  CompositMapperGenerator.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/9/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

public struct CompositeMapperGenerator {
    public enum Error: String, ErrorType {
        case ReducedTooMuch = "Reduced too much"
        case NotReducedEnough = "Not reduced enough"
    }

    let pipeline: [Transformer]

    public init() {
        self.pipeline = []
    }

    init(pipeline: [Transformer]) {
        self.pipeline = pipeline
    }

    public func split(splitter: Splitter) -> CompositeMapperGenerator {
        return CompositeMapperGenerator(pipeline: self.pipeline + [splitter])
    }

    public func map(mapper: Mapper) -> CompositeMapperGenerator {
        return CompositeMapperGenerator(pipeline: self.pipeline + [mapper])
    }

    public func map(function: (String) -> (String)) -> CompositeMapperGenerator {
        let mapper = FunctionMapper(function)
        return self.map(mapper)
    }

    public func reduce(reducer: Reducer) -> CompositeMapperGenerator {
        return CompositeMapperGenerator(pipeline: self.pipeline + [reducer])
    }

    public func generate() throws -> CompositeMapper {
        var depth = 0
        for transformer in self.pipeline {
            switch transformer {
            case _ as Reducer:
                depth -= 1
                if depth < 0 {
                    throw Error.ReducedTooMuch
                }
            case _ as Splitter:
                depth += 1
            case _ as Mapper:
                break
            default:
                break
            }
        }
        if depth != 0 {
            throw Error.NotReducedEnough
        }
        return CompositeMapper(pipeline: self.pipeline)
    }
}
