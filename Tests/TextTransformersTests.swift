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
    func testFunctionMapper() {
        let transformer = FunctionMapper({$0.lowercaseString})
        XCTAssertEqual(transformer.map("A,B,C,D"), "a,b,c,d")
    }

    func testSeperatorSplitter() {
        let splitter = SeperatorSplitter(seperator: ",")
        XCTAssertEqual(splitter.split("A,B,C,D"), ["A","B","C","D"])
    }

    func testComposite() {
        let composite = try! CompositeMapperGenerator()
            .split(SeperatorSplitter(seperator: ","))
            .reduce(SeperatorReducer(seperator: "-"))
            .map({$0.lowercaseString})
            .generate()

        XCTAssertEqual(composite.map("A,B,C,D"), "a-b-c-d")
    }

    func testCompositeTooReduced() {
        XCTAssertThrowsError(try CompositeMapperGenerator()
            .reduce(SeperatorReducer(seperator: "-"))
            .generate()
        )
    }

    func testCompositeNotReducedEnough() {
        XCTAssertThrowsError(try CompositeMapperGenerator()
            .split(SeperatorSplitter(seperator: ","))
            .generate()
        )
    }

    func testEmptyComposite() {
        let composite = try! CompositeMapperGenerator()
            .generate()

        XCTAssertEqual(composite.map("A,B,C,D"), "A,B,C,D")
    }
}
