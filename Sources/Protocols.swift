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

import Foundation

public protocol Transformer {}

public protocol Mapper: Transformer {
    func map(_ input: String) throws -> String
}

public protocol StreamMapper: Mapper {
    func map(_ input: CharacterInputStream, to output: CharacterOutputStream) throws
}

public protocol Splitter: Transformer {
    func split(_ input: String) throws -> [String]
}

public protocol Reducer: Transformer {
    mutating func reduce(_ input: String) throws
    func copy() -> Reducer
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
    var pipeline: [TransformPipe] {get}
}

public enum TransformPipe {
    case split(Splitter)
    case map(Mapper)
    case reduce(Reducer)
    case consolidatedReduce(ConsolidatedReducer)
    case filter(Filter)
    case consolidatedFilter(ConsolidatedFilter)
}

public protocol ComboMapper: ComboTransformer, Mapper {
}

extension ComboMapper {
    public func map(_ input: String) throws -> String {
        return try self.apply(input: .string(input)).allValues.first ?? ""
    }

    public func map(_ input: [String]) throws -> String {
        return try self.apply(input: .array(input)).allValues.first ?? ""
    }
}

extension ComboTransformer {
    func apply(input: IntermediateInputType) throws -> Intermediate {
        var intermediate: Intermediate
        switch input {
        case .array(let array):
            intermediate = Intermediate(array: array)
        case .string(let string):
            intermediate = Intermediate(string: string)
        }
        for pipe in self.pipeline {
            switch pipe {
            case .split(let splitter):
                intermediate = try intermediate.apply(splitter: splitter)
            case .map(let mapper):
                intermediate = try intermediate.apply(mapper: mapper)
            case .reduce(let some):
                intermediate = try intermediate.apply(reducer: some)
            case .filter(let filter):
                intermediate = try intermediate.apply(filter: filter)
            case .consolidatedFilter(let consolidatedFilter):
                intermediate = try intermediate.apply(filter: consolidatedFilter)
            case .consolidatedReduce(let consolidatedReducer):
                intermediate = try intermediate.apply(reducer: consolidatedReducer)
            }
        }

        return intermediate
    }
}

extension StreamMapper {
    public func map(_ input: String) throws -> String {
        let inputStream = CharacterInputStream(string: input)
        let outputStream = CharacterOutputStream()
        try self.map(inputStream, to: outputStream)
        return outputStream.output
    }
}
