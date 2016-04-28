//
//  TemplateMapperCommandDefault.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/28/16.
//  Copyright © 2016 Drewag. All rights reserved.
//
//
struct TemplateMapperCommandDefault: TemplateMapperCommand {
    func append(_ character: Character, to output: inout String) {
        output.append(character)
    }

    func append(_ string: String, to output: inout String) {
        output += string
    }

    func extraValue(forKey key: String) -> String? { return nil }

    func end(output: inout String) -> String.CharacterView.Index? { return nil }
}