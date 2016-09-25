//
//  PositionTemplateTests.swift
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

class PositionTemplateTests: XCTestCase {
    // Reducer

    func testNoReference() {
        let array: [String] = []
        XCTAssertEqual(try array.reduce(PositionTemplate("noreferences")).string(), "")
    }

    func testReferenceFromStart() {
        let reducer = PositionTemplate("from $0 start")
        XCTAssertEqual(try ["the", "ERROR"].reduce(reducer).string(), "from the start")
    }

    func testReferenceFromEnd() {
        let reducer = PositionTemplate("from $-0 end")
        XCTAssertEqual(reducer.reduce(["ERROR", "the"]), "from the end")
    }

    func testEscapedReference() {
        let reducer = PositionTemplate("show me the \\$1!!")
        XCTAssertEqual(try ["INPUT"].reduce(reducer).string(), "show me the $1!!")
    }

    func testMultipleReferences() {
        let reducer = PositionTemplate("$0 $1 $-0")
        XCTAssertEqual(try ["ONE", "TWO", "ERROR", "THREE"].reduce(reducer).string(), "ONE TWO THREE")
    }

    func testRefereneceWithoutSpaceAfter() {
        let reducer = PositionTemplate("$0$1$-0")
        XCTAssertEqual(try ["ONE", "TWO", "ERROR", "THREE"].reduce(reducer).string(), "ONETWOTHREE")
    }

    func testDollarSignOnItsOwn() {
        var reducer = PositionTemplate("show me the $!!")
        XCTAssertEqual(try [""].reduce(reducer).string(), "show me the $!!")

        reducer = PositionTemplate("show me the $")
        XCTAssertEqual(try [""].reduce(reducer).string(), "show me the $")
    }

    func testFromStartIndexOutOfBounds() {
        let reducer = PositionTemplate("from $10 start")
        XCTAssertEqual(try ["the", "ERROR"].reduce(reducer).string(), "from <INDEX OUT OF BOUNDS> start")
    }

    func testFromEndIndexOutOfBounds() {
        let reducer = PositionTemplate("from $-10 end")
        XCTAssertEqual(try ["ERROR", "the"].reduce(reducer).string(), "from <INDEX OUT OF BOUNDS> end")
    }
}