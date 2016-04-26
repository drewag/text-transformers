//
//  SurroundMapper.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/13/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

import Foundation

public struct SurroundMapper: ComboMapper {
    let prefix: String
    let suffix: String

    public init(_ prefix: String, _ suffix: String) {
        self.prefix = prefix
        self.suffix = suffix
    }

    public var pipeline: [Transformer] {
        return [
            NonSplitter(),
            TemplateReducer(template: "\(self.prefix)$0\(self.suffix)")
        ]
    }
}