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
    enum Element {
        case Value(String)
        case Seperator(level: Int)
    }

    private let depth: Int
    private let elements: [Element]

    init(elements: [Element], depth: Int) {
        self.elements = elements
        self.depth = depth
    }

    var allValues: [String] {
        return self.elements.map({ element in
            switch element {
            case .Value(let value):
                return value
            case .Seperator(_):
                return nil
            }
        }).flatMap({$0})
    }

    func apply(splitter: Splitter) -> Intermediate {
        let newDepth = self.depth + 1
        var elements = [Element]()

        for element in self.elements {
            switch element {
            case .Seperator(_):
                elements.append(element)
            case .Value(let value):
                for nextValue in splitter.split(value) {
                    elements.append(.Value(nextValue))
                    elements.append(.Seperator(level: newDepth))
                }
                elements.removeLast()
            }
        }

        return Intermediate(elements: elements, depth: newDepth)
    }

    func apply(mapper: Mapper) -> Intermediate {
        return Intermediate(elements: elements.map({ element in
            switch element {
            case .Seperator(_):
                return element
            case .Value(let value):
                return .Value(mapper.map(value))
            }
        }), depth: self.depth)
    }

    func apply(filter: Filter) -> Intermediate {
        return Intermediate(elements: elements.filter({ element in
            switch element {
            case .Seperator(_):
                return true
            case .Value(let value):
                return filter.filter(value)
            }
        }), depth: self.depth)
    }

    func apply(reducerTemplate: Reducer) -> Intermediate {
        var elements = [Element]()
        let newDepth = self.depth - 1
        var reducer = reducerTemplate.new()
        var didReduce = false

        for element in self.elements {
            switch element {
            case .Seperator(let depth):
                if depth != self.depth {
                    if didReduce {
                        elements.append(.Value(reducer.value))
                        didReduce = false
                    }
                    reducer = reducerTemplate.new()
                }
                elements.append(element)
            case .Value(let value):
                reducer.reduce(value)
                didReduce = true
            }
        }

        if didReduce {
            elements.append(.Value(reducer.value))
        }

        return Intermediate(elements: elements, depth: newDepth)
    }
}