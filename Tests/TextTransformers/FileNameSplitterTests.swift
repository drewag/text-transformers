//
//  BasenameMapperTests.swift
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

class FileNameSplitterTests: XCTestCase {
    let splitter = FileNameSplitter()

    func testSplitFullPath() {
        let parts = splitter.split("pa.th/to/a/fi.le.txt")
        XCTAssertEqual(parts.count, 3)
        XCTAssertEqual(parts[0], "pa.th/to/a")
        XCTAssertEqual(parts[1], "fi.le")
        XCTAssertEqual(parts[2], "txt")
    }

    func testSplitFileName() {
        let parts = splitter.split("fi.le.txt")
        XCTAssertEqual(parts.count, 3)
        XCTAssertEqual(parts[0], "")
        XCTAssertEqual(parts[1], "fi.le")
        XCTAssertEqual(parts[2], "txt")
    }

    func testSplitWithoutExtension() {
        let parts = splitter.split("pa.th/to/a/file")
        XCTAssertEqual(parts.count, 3)
        XCTAssertEqual(parts[0], "pa.th/to/a")
        XCTAssertEqual(parts[1], "file")
        XCTAssertEqual(parts[2], "")
    }

    func testSplitOfPlainText() {
        let parts = splitter.split("just some text")
        XCTAssertEqual(parts.count, 3)
        XCTAssertEqual(parts[0], "")
        XCTAssertEqual(parts[1], "just some text")
        XCTAssertEqual(parts[2], "")
    }

    func testSplitWithJustDot() {
        let parts = splitter.split("just.some.text")
        XCTAssertEqual(parts.count, 3)
        XCTAssertEqual(parts[0], "")
        XCTAssertEqual(parts[1], "just.some")
        XCTAssertEqual(parts[2], "text")
    }
}
