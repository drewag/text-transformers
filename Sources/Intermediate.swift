//
//  Intermediate.swift
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

struct Intermediate {
    enum Element: CustomStringConvertible {
        case Value(String)
        case Opening(count: Int)
        case Closing(count: Int)

        var description: String {
            switch self {
            case .Value(let value):
                return value
            case .Opening(let count):
                var output = ""
                for _ in 0 ..< count {
                    output += "["
                }
                return output
            case .Closing(let count):
                var output = ""
                for _ in 0 ..< count {
                    output += "]"
                }
                return output
            }
        }
    }

    private let depth: Int
    private let elements: [Element]

    init(string: String) {
        self.elements = [.Value(string)]
        self.depth = 0
    }

    init(array: [String]) {
        var output = [Element]()
        for element in array {
            output.append(.Opening(count: 0))
            output.append(.Value(element))
            output.append(.Closing(count: 0))
        }
        self.elements = output
        self.depth = 1
    }

    private init(elements: [Element], depth: Int) {
        self.elements = elements
        self.depth = depth
    }

    var allValues: [String] {
        return self.elements.map({ element in
            switch element {
            case .Value(let value):
                return value
            case .Opening(_), .Closing(_):
                return nil
            }
        }).flatMap({$0})
    }

    func apply(splitter: Splitter) throws -> Intermediate {
        let newDepth = self.depth + 1
        var elements = [Element]()

        for element in self.elements {
            switch element {
            case .Opening(let count):
                elements.append(.Opening(count: count + 1))
            case .Closing(let count):
                elements.append(.Closing(count: count + 1))
            case .Value(let value):
                for nextValue in try splitter.split(value) {
                    elements.append(.Opening(count: 0))
                    elements.append(.Value(nextValue))
                    elements.append(.Closing(count: 0))
                }
            }
        }

        return Intermediate(elements: elements, depth: newDepth)
    }

    func apply(mapper: Mapper) throws -> Intermediate {
        return Intermediate(elements: try elements.map({ element in
            switch element {
            case .Opening(_), .Closing(_):
                return element
            case .Value(let value):
                return .Value(try mapper.map(value))
            }
        }), depth: self.depth)
    }

    func apply(filter: Filter) throws -> Intermediate {
        return Intermediate(elements: try elements.filter({ element in
            switch element {
            case .Opening(_), .Closing(_):
                return true
            case .Value(let value):
                return try filter.filter(value)
            }
        }), depth: self.depth)
    }

    func apply(filter consolidatedFilter: ConsolidatedFilter) throws -> Intermediate {
        var consolidated = [String]()
        var elements = [Element]()
        for element in self.elements {
            switch element {
            case .Opening(let count):
                elements.append(.Opening(count: count))
            case .Closing(let count):
                if count > 0 {
                    if !consolidated.isEmpty {
                        for value in try consolidatedFilter.filter(consolidated) {
                            elements.append(.Opening(count: 0))
                            elements.append(.Value(value))
                            elements.append(.Closing(count: 0))
                        }
                        consolidated = []
                    }
                }
                elements.append(.Closing(count: count))
            case .Value(let value):
                consolidated.append(value)
            }
        }

        if !consolidated.isEmpty {
            for value in try consolidatedFilter.filter(consolidated) {
                elements.append(.Opening(count: 0))
                elements.append(.Value(value))
                elements.append(.Closing(count: 0))
            }
        }

        return Intermediate(elements: elements, depth: self.depth)
    }

    func apply(reducer reducerTemplate: Reducer) throws -> Intermediate {
        var elements = [Element]()
        let newDepth = self.depth - 1
        var reducer = reducerTemplate.new()
        var didReduce = false

        for element in self.elements {
            switch element {
            case .Opening(let count):
                if count > 0 {
                    elements.append(.Opening(count: count - 1))
                }
            case .Closing(let count):
                if count > 0 {
                    if didReduce {
                        elements.append(.Value(reducer.value))
                        didReduce = false
                        reducer = reducerTemplate.new()
                    }
                    elements.append(.Closing(count: count - 1))
                }
            case .Value(let value):
                try reducer.reduce(value)
                didReduce = true
            }
        }

        if didReduce {
            elements.append(.Value(reducer.value))
        }

        return Intermediate(elements: elements, depth: newDepth)
    }

    func apply(reducer consolidatedReducer: ConsolidatedReducer) throws -> Intermediate {
        var elements = [Element]()
        var consolidated = [String]()
        let newDepth = self.depth - 1

        for element in self.elements {
            switch element {
            case .Opening(let count):
                if count > 0 {
                    elements.append(.Opening(count: count - 1))
                }
            case .Closing(let count):
                if count > 0 {
                    if !consolidated.isEmpty {
                        let reduced = try consolidatedReducer.reduce(consolidated)
                        elements.append(.Value(reduced))
                        consolidated = []
                    }
                }
            case .Value(let value):
                consolidated.append(value)
            }
        }

        if !consolidated.isEmpty {
            let reduced = try consolidatedReducer.reduce(consolidated)
            elements.append(.Value(reduced))
            consolidated = []
        }

        return Intermediate(elements: elements, depth: newDepth)
    }
}
