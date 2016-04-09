//
//  FunctionMapper.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/9/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

import Foundation

public struct FunctionMapper: Mapper {
    let function: (String) -> (String)

    public init(_ function: (String) -> (String)) {
        self.function = function
    }

    public func map(input: String) -> String {
        return function(input)
    }
}