//
//  RangeFilter.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/11/16.
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

public struct RangeFilter: ConsolidatedFilter {
    public enum Spec {
        case FromBeginning(Int)
        case FromEnd(Int)

        func indexWithTotal(total: Int) -> Int {
            switch self {
            case .FromEnd(let end):
                return total - end - 1
            case .FromBeginning(let beginning):
                return beginning
            }
        }
    }

    private let start: Spec
    private let end: Spec

    public init(start: Spec = .FromBeginning(0), end: Spec = .FromEnd(0)) {
        self.start = start
        self.end = end
    }

    public func filter(input: [String]) -> [String] {
        let total = input.count
        var output = [String]()
        for (index, element) in input.enumerate() {
            if isAfterStart(element, index: index, total: total) &&
                isBeforeEnd(element, index: index, total: total)
            {
                output.append(element)
            }
        }
        return output
    }

    func isAfterStart(input: String, index: Int, total: Int) -> Bool {
        let referenceIndex = self.start.indexWithTotal(total)
        return index >= referenceIndex
    }

    func isBeforeEnd(input: String, index: Int, total: Int) -> Bool {
        let referenceIndex = self.end.indexWithTotal(total)
        return index <= referenceIndex
    }
}