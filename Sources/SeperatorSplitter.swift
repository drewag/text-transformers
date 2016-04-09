//
//  SeperatorSplitter.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/9/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

public struct SeperatorSplitter: Splitter {
    let seperator: String

    public init(seperator: String) {
        self.seperator = seperator
    }

    public func split(input: String) -> [String] {
        return input.componentsSeparatedByString(self.seperator)
    }
}