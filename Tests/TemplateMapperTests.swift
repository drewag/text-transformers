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
        let mapper = TemplateMapper(build: { builder in
            builder["value1"] = "World"
            builder["value2"] = "Example 2"
        })

        let template = "<h1>Hello {{   value1  }}!!!</h1><p>{{value2}}</p>"
        XCTAssertEqual(try template.map(mapper).string(), "<h1>Hello World!!!</h1><p>Example 2</p>")
    }

    func testConditional() {
        var mapper = TemplateMapper(build: { builder in
            builder["error"] = "There was an error"
        })

        let template = "Login {{ if error }} Error: {{ error }} {{end}} End"
        XCTAssertEqual(try template.map(mapper).string(), "Login  Error: There was an error  End")

        mapper = TemplateMapper(build: { builder in
        })
        XCTAssertEqual(try template.map(mapper).string(), "Login  End")

        mapper = TemplateMapper(build: { builder in
            builder["error"] = "There was an error"
            builder.buildValues(forKey: "other", withArray: ["value1"], build: { value, builder in
            })
        })

        let template2 = "Login {{if other}} Error: {{ error }} {{end}} End"
        XCTAssertEqual(try template2.map(mapper).string(), "Login  Error: There was an error  End")
    }

    func testLoops() {
        var mapper = TemplateMapper(build: { builder in
            builder["prefix"] = "-"
            builder.buildValues(forKey: "listItems", withArray: ["value1", "value2", "value3"], build: { value, builder in
                builder["item"] = value
            })
        })

        let template = "List Items:{{ repeat listItems }}\n{{prefix}} {{item}}{{ end }}"
        XCTAssertEqual(try template.map(mapper).string(), "List Items:\n- value1\n- value2\n- value3")

        mapper = TemplateMapper(build: { builder in
            builder.buildValues(forKey: "listItems", withArray: [], build: { (value: String, builder) in })
            builder["prefix"] = "-"
        })
        XCTAssertEqual(try template.map(mapper).string(), "List Items:")

        mapper = TemplateMapper(build: { builder in
            builder["prefix"] = "-"
        })
        XCTAssertEqual(try template.map(mapper).string(), "List Items:")
    }

    func testNestedLoops() {
        var mapper = TemplateMapper(build: { builder in
            builder["prefix"] = "-"
            builder.buildValues(forKey: "listItems", withArray: ["value1", "value2", "value3"], build: { value, builder in
                builder.buildValues(forKey: "subItems", withArray: ["sub1", "sub2", "sub3"], build: { value, builder in
                    builder["item"] = value
                })
            })
        })

        let template = "List Items:{{ repeat listItems }}\n{{prefix}} {{repeat subItems}}{{item}}{{end}}{{ end }}"
        XCTAssertEqual(try template.map(mapper).string(), "List Items:\n- sub1sub2sub3\n- sub1sub2sub3\n- sub1sub2sub3")

        mapper = TemplateMapper(build: { builder in
            builder.buildValues(forKey: "listItems", withArray: [], build: { (value: String, builder) in })
            builder["prefix"] = "-"
        })
        XCTAssertEqual(mapper.map(template), "List Items:")

        mapper = TemplateMapper(build: { builder in
            builder["prefix"] = "-"
        })
        XCTAssertEqual(try template.map(mapper).string(), "List Items:")
    }
}
