//
//  RangeFilterTests.swift
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

import XCTest
import TextTransformers

class RangeFilterTests: XCTestCase {
    let elements = "0,1,2,3"

    func testFixedEnds() {
        let mapper = try! CompositeMapperGenerator()
            .split(SeperatorSplitter(seperator: ","))
            .filter(RangeFilter(start: .FromBeginning(1), end: .FromEnd(1)))
            .reduce(SeperatorReducer(seperator: ""))
            .generate()

        XCTAssertEqual(mapper.map(self.elements), "12")
    }

    func testFromBeginning() {
        let mapper = try! CompositeMapperGenerator()
            .split(SeperatorSplitter(seperator: ","))
            .filter(RangeFilter(start: .FromBeginning(1), end: .FromBeginning(2)))
            .reduce(SeperatorReducer(seperator: ""))
            .generate()

        XCTAssertEqual(mapper.map(self.elements), "12")
    }

    func testFromEnd() {
        let mapper = try! CompositeMapperGenerator()
            .split(SeperatorSplitter(seperator: ","))
            .filter(RangeFilter(start: .FromEnd(2), end: .FromEnd(1)))
            .reduce(SeperatorReducer(seperator: ""))
            .generate()

        XCTAssertEqual(mapper.map(self.elements), "12")
    }

    func testFromOposites() {
        let mapper = try! CompositeMapperGenerator()
            .split(SeperatorSplitter(seperator: ","))
            .filter(RangeFilter(start: .FromEnd(2), end: .FromBeginning(2)))
            .reduce(SeperatorReducer(seperator: ""))
            .generate()

        XCTAssertEqual(mapper.map(self.elements), "12")
    }

    func testAll() {
        let mapper = try! CompositeMapperGenerator()
            .split(SeperatorSplitter(seperator: ","))
            .filter(RangeFilter(start: .FromBeginning(0), end: .FromEnd(0)))
            .reduce(SeperatorReducer(seperator: ""))
            .generate()

        XCTAssertEqual(mapper.map(self.elements), "0123")
    }

    func testSingleFromBeginning() {
        let mapper = try! CompositeMapperGenerator()
            .split(SeperatorSplitter(seperator: ","))
            .filter(RangeFilter(start: .FromBeginning(1), end: .FromBeginning(1)))
            .reduce(SeperatorReducer(seperator: ""))
            .generate()

        XCTAssertEqual(mapper.map(self.elements), "1")
    }

    func testSingleFromEnd() {
        let mapper = try! CompositeMapperGenerator()
            .split(SeperatorSplitter(seperator: ","))
            .filter(RangeFilter(start: .FromEnd(1), end: .FromEnd(1)))
            .reduce(SeperatorReducer(seperator: "1"))
            .generate()

        XCTAssertEqual(mapper.map(self.elements), "2")
    }
}
