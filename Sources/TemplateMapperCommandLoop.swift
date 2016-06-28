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

    private var output = ""

    init(startIndex: String.CharacterView.Index, values: [TemplateMapperValues]) {
        self.startIndex = startIndex
        self.values = values
    }

    func append(_ string: String) {
        if self.index < self.values.count {
            self.output += string
        }
    }

    func append(_ character: Character) {
        if self.index < self.values.count {
            self.output.append(character)
        }
    }

    func extraValue(forKey key: String) -> String? {
        guard index < self.values.count else {
            return nil
        }
        return self.values[index].string(forKey: key)
    }

    func extraValues(forKey key: String) -> [TemplateMapperValues]? {
        guard index < self.values.count else {
            return nil
        }
        return self.values[index].values(forKey: key)
    }

    func end() -> (output: String, newIndex: String.CharacterView.Index?) {
        let thisOutput = output

        if index < values.count {
            self.output = ""
            index += 1
        }

        if index < values.count {
            return (output: thisOutput, self.startIndex)
        }
        return (output: thisOutput, nil)
    }
}