//
//  TemplateMapperCommandLoop.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/28/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

class TemplateMapperCommandLoop: TemplateMapperCommand {
    let startIndex: String.CharacterView.Index
    let values: [TemplateMapperValues]
    var index: Int = 0

    var internalOutput = ""

    init(startIndex: String.CharacterView.Index, values: [TemplateMapperValues]) {
        self.startIndex = startIndex
        self.values = values
    }

    func append(_ string: String, to output: inout String) {
        internalOutput += string
    }

    func append(_ character: Character, to output: inout String) {
        internalOutput.append(character)
    }

    func extraValue(forKey key: String) -> String? {
        guard index < self.values.count else {
            return nil
        }
        return self.values[index].string(forKey: key)
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