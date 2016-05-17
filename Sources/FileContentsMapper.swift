//
//  FileContentsMapper.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/25/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

import Foundation

public struct FileContentsMapper: Mapper {
    public init() {}

    public func map(_ input: String) -> String {
        return (try? String(contentsOfFile: input)) ?? ""
    }
}
