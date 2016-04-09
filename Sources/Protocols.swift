//
//  Protocols.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/9/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

public protocol Transformer {}

public protocol Mapper: Transformer {
    func map(input: String) -> String
}

public protocol Splitter: Transformer {
    func split(input: String) -> [String]
}

public protocol Reducer: Transformer {
    mutating func reduce(input: String)
    func new() -> Self
    var value: String { get }
}