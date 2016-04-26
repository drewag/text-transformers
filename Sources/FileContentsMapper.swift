//
//  FileContentsMapper.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/25/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Foundation
#endif

public struct FileContentsMapper: Mapper {
    public init() {}

    public func map(_ input: String) -> String {
        if let data = NSFileManager.defaultManager().contents(atPath: input) {
            return String(data: data, encoding: NSUTF8StringEncoding) ?? ""
        }
        return ""
    }
}