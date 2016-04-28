//
//  TemplateMapperTests.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/26/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

import XCTest
import TextTransformers

class TemplateMapperTests: XCTestCase {
    func testVariableReplacements() {
        let mapper = TemplateMapper(values: [
            "value1": "World",
            "value2": "Example 2",
        ])

        let template = "<h1>Hello {{   value1  }}!!!</h1><p>{{value2}}</p>"
        XCTAssertEqual(mapper.map(template), "<h1>Hello World!!!</h1><p>Example 2</p>")
    }

    func testConditional() {
        var mapper = TemplateMapper(values: [
            "error": "There was an error",
        ])

        let template = "Login {{ if error }} Error: {{ error }} {{end}} End"
        XCTAssertEqual(mapper.map(template), "Login  Error: There was an error  End")

        mapper = TemplateMapper(values: [:])
        XCTAssertEqual(mapper.map(template), "Login  End")
    }

    func testLoops() {
        var mapper = TemplateMapper(values: [
            "listItems": ["value1", "value2", "value3"],
            "prefix": "-",
        ])

        let template = "List Items:{{ for item in listItems }}\n{{prefix}} {{item}}{{ end }}"
        XCTAssertEqual(mapper.map(template), "List Items:\n- value1\n- value2\n- value3")

        mapper = TemplateMapper(values: [
            "listItems": [],
            "prefix": "-",
        ])
        XCTAssertEqual(mapper.map(template), "List Items:")

        mapper = TemplateMapper(values: [
            "prefix": "-",
        ])
        XCTAssertEqual(mapper.map(template), "List Items:")
    }
}