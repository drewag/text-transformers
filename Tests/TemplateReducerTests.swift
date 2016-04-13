//
//  TemplateReducerTests.swift
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

import XCTest
import TextTransformers

class TemplateReducerTests: XCTestCase {
    func testNoReference() {
        let reducer = TemplateReducer(template: "noreferences")
        XCTAssertEqual(reducer.reduce([]), "noreferences")
    }

    func testReferenceFromStart() {
        let reducer = TemplateReducer(template: "from $0 start")
        XCTAssertEqual(reducer.reduce(["the", "ERROR"]), "from the start")
    }

    func testReferenceFromEnd() {
        let reducer = TemplateReducer(template: "from $-0 end")
        XCTAssertEqual(reducer.reduce(["ERROR", "the"]), "from the end")
    }

    func testEscapedReference() {
        let reducer = TemplateReducer(template: "show me the \\$1!!")
        XCTAssertEqual(reducer.reduce([]), "show me the $1!!")
    }

    func testMultipleReferences() {
        let reducer = TemplateReducer(template: "$0 $1 $-0")
        XCTAssertEqual(reducer.reduce(["ONE", "TWO", "ERROR", "THREE"]), "ONE TWO THREE")
    }

    func testRefereneceWithoutSpaceAfter() {
        let reducer = TemplateReducer(template: "$0$1$-0")
        XCTAssertEqual(reducer.reduce(["ONE", "TWO", "ERROR", "THREE"]), "ONETWOTHREE")
    }

    func testDollarSignOnItsOwn() {
        var reducer = TemplateReducer(template: "show me the $!!")
        XCTAssertEqual(reducer.reduce([]), "show me the $!!")

        reducer = TemplateReducer(template: "show me the $")
        XCTAssertEqual(reducer.reduce([]), "show me the $")
    }

    func testFromStartIndexOutOfBounds() {
        let reducer = TemplateReducer(template: "from $10 start")
        XCTAssertEqual(reducer.reduce(["the", "ERROR"]), "from <INDEX OUT OF BOUNDS> start")
    }

    func testFromEndIndexOutOfBounds() {
        let reducer = TemplateReducer(template: "from $-10 end")
        XCTAssertEqual(reducer.reduce(["ERROR", "the"]), "from <INDEX OUT OF BOUNDS> end")
    }
}