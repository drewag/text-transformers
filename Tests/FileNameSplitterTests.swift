//
//  BasenameMapperTests.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/11/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

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
