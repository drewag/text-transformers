//
//  TemplateMapperBuilder.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 5/3/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

import Foundation

public class TemplateMapperBuilder {
    private(set) var values = TemplateMapperValues()

    public subscript(key: String) -> String? {
        get {
            return self.values.string(forKey: key)
        }

        set {
            self.values.set(string: newValue, forKey: key)
        }
    }

    public func buildValues<ArrayElement>(forKey key: String, withArray array: [ArrayElement], build: (ArrayElement, TemplateMapperBuilder) -> ()) {
        let valuesList = array.map { (element: ArrayElement) -> TemplateMapperValues in
            let builder = TemplateMapperBuilder()
            build(element, builder)
            return builder.values
        }
        self.values.set(values: valuesList, forKey: key)
    }
}