//
//  SeperatorReducer.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/9/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

public struct SeperatorReducer: Reducer {
    let seperator: String
    var output: String = ""

    public init(seperator: String) {
        self.seperator = seperator
    }

    public mutating func reduce(input: String) {
        if self.output.isEmpty {
            self.output = input
        }
        else {
            self.output += "\(self.seperator)\(input)"
        }
    }

    public var value: String {
        return self.output
    }

    public func new() -> SeperatorReducer {
        return SeperatorReducer(seperator: seperator)
    }
}