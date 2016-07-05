//
//  TemplateCommandLoop.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/28/16.
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

class TemplateCommandLoop: TemplateCommand {
    private let startIndex: String.CharacterView.Index
    private let values: [TemplateValues]
    private var index: Int = 0

    private var output = ""

    init(startIndex: String.CharacterView.Index, values: [TemplateValues]) {
        self.startIndex = startIndex
        self.values = values
    }

    func append(_ string: String) {
        if self.index < self.values.count {
            self.output += string
        }
    }

    func append(_ character: Character) {
        if self.index < self.values.count {
            self.output.append(character)
        }
    }

    func extraValue(forKey key: String) -> String? {
        guard index < self.values.count else {
            return nil
        }
        return self.values[index].string(forKey: key)
    }

    func extraValues(forKey key: String) -> [TemplateValues]? {
        guard index < self.values.count else {
            return nil
        }
        return self.values[index].values(forKey: key)
    }

    func end() -> (output: String, newIndex: String.CharacterView.Index?) {
        let thisOutput = output

        if index < values.count {
            self.output = ""
            index += 1
        }

        if index < values.count {
            return (output: thisOutput, self.startIndex)
        }
        return (output: thisOutput, nil)
    }
}