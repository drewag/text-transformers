//
//  TemplateMapperValue.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/28/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

struct TemplateMapperValues {
    private var values = [String:Any]()

    init() {}

    func string(forKey key: String) -> String? {
        return self.values[key] as? String
    }

    func values(forKey key: String) -> [TemplateMapperValues]? {
        return self.values[key] as? [TemplateMapperValues]
    }

    mutating func set(string: String?, forKey key: String) {
        self.values[key] = string
    }

    mutating func set(values: [TemplateMapperValues]?, forKey key: String) {
        self.values[key] = values
    }
}
