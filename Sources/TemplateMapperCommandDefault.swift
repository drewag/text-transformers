//
//  TemplateMapperCommandDefault.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/28/16.
//  Copyright © 2016 Drewag. All rights reserved.
//
//
class TemplateMapperCommandDefault: TemplateMapperCommand {
    private var output = ""

    func append(_ character: Character) {
        self.output.append(character)
    }

    func append(_ string: String) {
        self.output += string
    }

    func extraValue(forKey key: String) -> String? { return nil }
    func extraValues(forKey key: String) -> [TemplateMapperValues]? { return nil }

    func end() -> (output: String, newIndex: String.CharacterView.Index?) {
        return (output: output, newIndex: nil)
    }
}