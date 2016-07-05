//
//  FileContents.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/25/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

import XCTest
import TextTransformers

class FileContentsTests: XCTestCase {
    let directoryPath = NSBundle(for: DirectoryContentsTests.self).pathForResource("test_content", ofType: "")!

    func testContentsOfExistingFile() {
        XCTAssertEqual(try (self.directoryPath + "/file1.txt").map(FileContents()).string(), "example content")
    }

    func testContentsOfNonExistingFile() {
        XCTAssertEqual(try (directoryPath + "non-existent").map(FileContents()).string(), "")
    }
}
