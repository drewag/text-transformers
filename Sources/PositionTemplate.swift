//
//  PositionTemplate.swift
//  TextTransformers
//
//  Created by Andrew Wagner on 4/13/16.
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

public struct PositionTemplate: ConsolidatedReducer {
    // Templates look like this: "Fixed text with variables $0 and $-1 plus \$10 dollars."
    // - Placeholders start with a dollar sign ($)
    // - Positive values are referenced from the beginning of the input array
    // - Negative values are referenced from the end of the input array
    // - You can escape a dollar sign with a backslash (\)
    private let template: String

    public init(_ template: String) {
        self.template = template
    }

    public func reduce(_ input: [String]) -> String {
        var output = ""

        var readingReference = false
        var fromEndReference = false
        var referenceString = ""
        var skipNext = false

        func appendReference() {
            defer {
                readingReference = false
                fromEndReference = false
                referenceString = ""
            }

            guard !referenceString.isEmpty else {
                output += "$"
                return
            }

            var index = Int(referenceString)!
            if fromEndReference {
                index = input.count - 1 - index
            }
            if index < input.count && index >= 0 {
                output += input[index]
            }
            else {
                output += "<INDEX OUT OF BOUNDS>"
            }
        }

        func check(character: Character) {
            if character == "\\" {
                skipNext = true
            }
            else if character == "$" {
                readingReference = true
            }
            else  {
                output.append(character)
            }
        }

        for character in self.template.characters {
            guard !skipNext else {
                skipNext = false
                output.append(character)
                continue
            }

            guard readingReference else {
                check(character: character)
                continue
            }

            if referenceString.isEmpty && character == "-" {
                fromEndReference = true
            }
            else if character.isNumber {
                referenceString.append(character)
            }
            else {
                // End of reference
                appendReference()
                check(character: character)
            }
        }

        if readingReference {
            appendReference()
        }

        return output
    }
}

extension Character {
    var isNumber: Bool {
        return Int("\(self)") != nil
    }
}