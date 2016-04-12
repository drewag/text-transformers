//
//  DirectoryContentsSplitterTests.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/11/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

import XCTest
import TextTransformers

class DirectoryContentsSplitterTests: XCTestCase {
    let directoryPath = NSBundle(forClass: DirectoryContentsSplitterTests.self).pathForResource("test_content", ofType: "")!

    func testSplit() {
        let splitter = DirectoryContentsSplitter()
        let filePaths = splitter.split(self.directoryPath)

        XCTAssertEqual(filePaths.count, 3)
        XCTAssertTrue(filePaths.contains(directoryPath + "/file1.txt"))
        XCTAssertTrue(filePaths.contains(directoryPath + "/file2.md"))
        XCTAssertTrue(filePaths.contains(directoryPath + "/file3.txt"))
    }

    func testSplitWithSingleExtension() {
        let splitter = DirectoryContentsSplitter(fileExtensions: ["txt"])
        let filePaths = splitter.split(self.directoryPath)

        XCTAssertEqual(filePaths.count, 2)
        XCTAssertTrue(filePaths.contains(directoryPath + "/file1.txt"))
        XCTAssertTrue(filePaths.contains(directoryPath + "/file3.txt"))
    }

    func testSplitWithMultipleExtensions() {
        let splitter = DirectoryContentsSplitter(fileExtensions: ["txt", "md"])
        let filePaths = splitter.split(self.directoryPath)

        XCTAssertEqual(filePaths.count, 3)
        XCTAssertTrue(filePaths.contains(directoryPath + "/file1.txt"))
        XCTAssertTrue(filePaths.contains(directoryPath + "/file2.md"))
        XCTAssertTrue(filePaths.contains(directoryPath + "/file3.txt"))
    }
}
