//
//  TemplateMapperCommandLoop.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/28/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

class TemplateMapperCommandLoop: TemplateMapperCommand {
    let startIndex: String.CharacterView.Index
    let placeholderName: String
    let values: [String]
    var index: Int = 0

    var internalOutput = ""

    init(startIndex: String.CharacterView.Index, placeholderName: String, values: [String]) {
        self.startIndex = startIndex
        self.placeholderName = placeholderName
        self.values = values
    }

    func append(_ string: String, to output: inout String) {
        internalOutput += string
    }

    func append(_ character: Character, to output: inout String) {
        if character == "}" {
            print("ASDFAFS")
        }
        internalOutput.append(character)
    }

    func extraValue(forKey key: String) -> String? {
        if key == placeholderName && index < values.count {
            return values[index]
        }
        return nil
    }

    func end(output: inout String) -> String.CharacterView.Index? {
        if index < values.count {
            output.append(internalOutput)
            internalOutput = ""
            index += 1
        }

        if index < values.count {
            return self.startIndex
        }
        return nil
    }
}