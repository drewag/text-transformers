//
//  TextTransformersTests.swift
//  TextTransformersTests
//
//  Created by Andrew J Wagner on 4/9/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

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
