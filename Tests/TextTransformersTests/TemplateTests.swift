//
//  TemplateTests.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/26/16.
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

class TemplateTests: XCTestCase {
    func testVariableReplacements() throws {
        let mapper = try Template(build: { builder in
            builder["value1"] = "World"
            builder["value2"] = "Example 2"
        })

        let template = "<h1>Hello {{   value1  }}!!!</h1><p>{{value2}}</p>"
        XCTAssertEqual(try template.map(mapper).string(), "<h1>Hello World!!!</h1><p>Example 2</p>")
    }

    func testConditional() throws {
        var mapper = try Template(build: { builder in
            builder["error"] = "There was an error"
        })

        let template = "Login {{ if error }} Error: {{ error }} {{end}} End"
        XCTAssertEqual(try template.map(mapper).string(), "Login  Error: There was an error  End")

        mapper = try Template(build: { builder in
        })
        XCTAssertEqual(try template.map(mapper).string(), "Login  End")

        mapper = try Template(build: { builder in
            builder["error"] = "There was an error"
            builder.buildValues(forKey: "other", withArray: ["value1"], build: { value, builder in
            })
        })

        let template2 = "Login {{if other}} Error: {{ error }} {{end}} End"
        XCTAssertEqual(try template2.map(mapper).string(), "Login  Error: There was an error  End")
    }

    func testLoops() throws {
        var mapper = try Template(build: { builder in
            builder["prefix"] = "-"
            builder.buildValues(forKey: "listItems", withArray: ["value1", "value2", "value3"], build: { value, builder in
                builder["item"] = value
            })
        })

        let template = "List Items:{{ repeat listItems }}\n{{prefix}} {{item}}{{ end }}"
        XCTAssertEqual(try template.map(mapper).string(), "List Items:\n- value1\n- value2\n- value3")

        mapper = try Template(build: { builder in
            builder.buildValues(forKey: "listItems", withArray: [], build: { (value: String, builder) in })
            builder["prefix"] = "-"
        })
        XCTAssertEqual(try template.map(mapper).string(), "List Items:")

        mapper = try Template(build: { builder in
            builder["prefix"] = "-"
        })
        XCTAssertEqual(try template.map(mapper).string(), "List Items:")
    }

    func testNestedLoops() throws {
        var mapper = try Template(build: { builder in
            builder["prefix"] = "-"
            builder.buildValues(forKey: "listItems", withArray: ["value1", "value2", "value3"], build: { value, builder in
                builder.buildValues(forKey: "subItems", withArray: ["sub1", "sub2", "sub3"], build: { value, builder in
                    builder["item"] = value
                })
            })
        })

        let template = "List Items:{{ repeat listItems }}\n{{prefix}} {{repeat subItems}}{{item}}{{end}}{{ end }}"
        XCTAssertEqual(try template.map(mapper).string(), "List Items:\n- sub1sub2sub3\n- sub1sub2sub3\n- sub1sub2sub3")

        mapper = try Template(build: { builder in
            builder.buildValues(forKey: "listItems", withArray: [], build: { (value: String, builder) in })
            builder["prefix"] = "-"
        })
        XCTAssertEqual(mapper.map(template), "List Items:")

        mapper = try Template(build: { builder in
            builder["prefix"] = "-"
        })
        XCTAssertEqual(try template.map(mapper).string(), "List Items:")
    }
}
