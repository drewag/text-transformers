//
//  DirectoryContentsSplitter.swift
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

#if os(Linux)
    import Glibc
#else
    import Foundation
#endif

public struct DirectoryContentsSplitter: Splitter {
    let fileExtensions: [String]

    public init(fileExtensions: [String] = []) {
        self.fileExtensions = fileExtensions
    }

    public func split(input: String) -> [String] {
        do {
            let paths = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(input)
                .map {"\(input)/\($0)"}

            guard !self.fileExtensions.isEmpty else {
                return paths
            }

            return paths.filter({
                for fileExtension in self.fileExtensions {
                    if $0.lowercaseString.hasSuffix(".\(fileExtension.lowercaseString)") {
                        return true
                    }
                }
                return false
            })
        }
        catch {
            return []
        }
    }
}