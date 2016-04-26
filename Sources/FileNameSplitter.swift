//
//  FileNameSplitter.swift
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

public struct FileNameSplitter: Splitter {
    public init() {}

    public func split(_ input: String) -> [String] {
        var directory = ""
        var name = ""
        var fileExtension = ""

        var foundDot = false
        var foundSlash = false

        for character in input.characters.reversed() {
            if !foundDot && !foundSlash {
                switch character {
                case ".":
                    foundDot = true
                case "/":
                    name = fileExtension
                    fileExtension = ""
                    foundSlash = true
                default:
                    fileExtension.insert(character, at: fileExtension.startIndex)
                }
            }
            else if !foundSlash {
                if character == "/" {
                    foundSlash = true
                    continue
                }
                name.insert(character, at: name.startIndex)
            }
            else {
                directory.insert(character, at: directory.startIndex)
            }
        }

        if !foundDot && !foundSlash {
            return ["", input, ""]
        }

        return [directory, name, fileExtension]
    }
}