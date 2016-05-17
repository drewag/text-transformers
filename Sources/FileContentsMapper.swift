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
        let URL = NSURL(fileURLWithPath: input)
        return (try? String(contentsOfURL: URL)) ?? ""
    }
}
