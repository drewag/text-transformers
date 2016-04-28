//
//  Protocols.swift
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

public protocol Transformer {}

public protocol Mapper: Transformer {
    func map(_ input: String) throws -> String
}

public protocol Splitter: Transformer {
    func split(_ input: String) throws -> [String]
}

public protocol Reducer: Transformer {
    mutating func reduce(_ input: String) throws
    func new() -> Self
    var value: String { get }
}

public protocol ConsolidatedReducer: Transformer {
    func reduce(_ input: [String]) throws -> String
}

public protocol Filter: Transformer {
    func filter(_ input: String) throws -> Bool
}

public protocol ConsolidatedFilter: Transformer {
    func filter(_ input: [String]) throws -> [String]
}

public protocol ComboTransformer: Transformer {
    var pipeline: [Transformer] {get}
}

public protocol ComboMapper: ComboTransformer, Mapper {
}

extension ComboMapper {
    public func map(_ input: String) throws -> String {
        var intermediate = Intermediate(elements: [.Value(input)], depth: 0)

        for transformer in self.pipeline {
            switch transformer {
            case let splitter as Splitter:
                intermediate = try intermediate.apply(splitter: splitter)
            case let mapper as Mapper:
                intermediate = try intermediate.apply(mapper: mapper)
            case let reducer as Reducer:
                intermediate = try intermediate.apply(reducer: reducer)
            case let filter as Filter:
                intermediate = try intermediate.apply(filter: filter)
            case let consolidatedFilter as ConsolidatedFilter:
                intermediate = try intermediate.apply(filter: consolidatedFilter)
            case let consolidatedReducer as ConsolidatedReducer:
                intermediate = try intermediate.apply(reducer: consolidatedReducer)
            default:
                break
            }
        }

        return intermediate.allValues.first ?? ""
    }
}