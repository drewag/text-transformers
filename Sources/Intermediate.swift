//
//  Intermediate.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/9/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

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