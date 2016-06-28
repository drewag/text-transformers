//
//  TemplateMapperCommandIf.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/28/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

class TemplateMapperCommandIf: TemplateMapperCommand {
    private let passed: Bool
    private var output = ""

    init(passed: Bool) {
        self.passed = passed
    }

    func append(_ character: Character) {
        if self.passed {
            self.output.append(character)
        }
    }

    func append(_ string: String) {
        if self.passed {
            self.output += string
        }
    }

    func extraValue(forKey key: String) -> String? { return nil }
    func extraValues(forKey key: String) -> [TemplateMapperValues]? { return nil }

    func end() -> (output: String, newIndex: String.CharacterView.Index?) {
        return (output: output, newIndex: nil)
    }
}