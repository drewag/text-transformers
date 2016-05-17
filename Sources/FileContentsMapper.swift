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
#endif

public struct FileContentsMapper: Mapper {
   public init() {}

   public func map(_ input: String) -> String {
       #if os(Linux)
           let BUFSIZE = 1024
           let pp = popen("cat " + input, "r")
           var buf = [CChar](repeating: CChar(0), count:BUFSIZE)

           var output = ""
           while fgets(&buf, Int32(BUFSIZE), pp) != nil {
               output += String(cString: buf)
           }
           return output
       #else
           return (try? String(contentsOfFile: input)) ?? ""
       #endif
    }
}
