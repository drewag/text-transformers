//
//  TemplateMapperCommandIf.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/28/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

struct TemplateMapperCommandIf: TemplateMapperCommand {
    let passed: Bool

    func append(_ character: Character, to output: inout String) {
        if self.passed {
            output.append(character)
        }
    }

    func append(_ string: String, to output: inout String) {
        if self.passed {
            output += string
        }
    }

    func extraValue(forKey key: String) -> String? { return nil }

    func end(output: inout String) -> String.CharacterView.Index? { return nil }
}