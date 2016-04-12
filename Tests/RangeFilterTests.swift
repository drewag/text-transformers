//
//  RangeFilterTests.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/11/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

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
