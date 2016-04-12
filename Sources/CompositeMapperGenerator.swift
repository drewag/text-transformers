//
//  CompositMapperGenerator.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/9/16.
//  Copyright © 2016 Drewag. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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

    public func filter(filter: Filter) -> CompositeMapperGenerator {
        return CompositeMapperGenerator(pipeline: self.pipeline + [filter])
    }

    public func filter(function: (String) -> Bool) -> CompositeMapperGenerator {
        let filter = FunctionWithoutIndexFilter(function)
        return self.filter(filter)
    }

    public func filter(function: (element: String, index: Int, total: Int) -> Bool) -> CompositeMapperGenerator {
        let filter = FunctionFilter(function)
        return self.filter(filter)
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
