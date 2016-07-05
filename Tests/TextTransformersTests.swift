//
//  TextTransformersTests.swift
//  TextTransformersTests
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

import XCTest
import TextTransformers

class TextTransformersTests: XCTestCase {
    func testSeparatorSplitter() {
        XCTAssertEqual(try "A,B,C,D".split(Separator(",")).array(), ["A","B","C","D"])
    }

    func testComposite() throws {
        let output = try "A,B,Z,C,D"
            .split(Separator(","))
            .filter({$0 != "Z"})
            .map({$0.lowercased()})
            .reduce(Separator("-"))
            .split(Separator("_"))
            .reduce(PositionTemplate("<$0>"))
            .string()

        XCTAssertEqual(output, "<a-b-c-d>")
    }
}
