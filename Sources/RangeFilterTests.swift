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
            .filter(RangeFilter(start: .FromBeginning(1), end: .FromBeginning(3)))
            .reduce(SeperatorReducer(seperator: ""))
            .generate()

        XCTAssertEqual(mapper.map(self.elements), "12")
    }

    func testFromEnd() {
        let mapper = try! CompositeMapperGenerator()
            .split(SeperatorSplitter(seperator: ","))
            .filter(RangeFilter(start: .FromEnd(3), end: .FromEnd(1)))
            .reduce(SeperatorReducer(seperator: ""))
            .generate()

        XCTAssertEqual(mapper.map(self.elements), "12")
    }

    func testFromOposites() {
        let mapper = try! CompositeMapperGenerator()
            .split(SeperatorSplitter(seperator: ","))
            .filter(RangeFilter(start: .FromEnd(3), end: .FromBeginning(3)))
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
}
