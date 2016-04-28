//
//  SurroundMapperTests.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/13/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

import XCTest
import TextTransformers

class SurroundMapperTests: XCTestCase {
    func test() {
        let mapper = SurroundMapper("<", ">")
        XCTAssertEqual(try mapper.map("input"), "<input>")
    }
}
