//
//  FileNameSplitter.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/11/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

public struct FileNameSplitter: Splitter {
    public init() {}

    public func split(input: String) -> [String] {
        var directory = ""
        var name = ""
        var fileExtension = ""

        var foundDot = false
        var foundSlash = false

        for character in input.characters.reverse() {
            if !foundDot && !foundSlash {
                switch character {
                case ".":
                    foundDot = true
                case "/":
                    name = fileExtension
                    fileExtension = ""
                    foundSlash = true
                default:
                    fileExtension.insert(character, atIndex: fileExtension.startIndex)
                }
            }
            else if !foundSlash {
                if character == "/" {
                    foundSlash = true
                    continue
                }
                name.insert(character, atIndex: name.startIndex)
            }
            else {
                directory.insert(character, atIndex: directory.startIndex)
            }
        }

        if !foundDot && !foundSlash {
            return ["", input, ""]
        }

        return [directory, name, fileExtension]
    }
}