//
//  FileContentsMapper.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/25/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

import XCTest
import TextTransformers

class FileContentsMapperTests: XCTestCase {
    let directoryPath = NSBundle(for: DirectoryContentsSplitterTests.self).pathForResource("test_content", ofType: "")!

    func testContentsOfExistingFile() {
        let mapper = FileContentsMapper()

        XCTAssertEqual(mapper.map(directoryPath + "/file1.txt"), "example content")
    }

    func testContentsOfNonExistingFile() {
        let mapper = FileContentsMapper()

        XCTAssertEqual(mapper.map(directoryPath + "non-existent"), "")
    }
}
