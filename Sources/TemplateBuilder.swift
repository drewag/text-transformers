//
//  TemplateBuilder.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 5/3/16.
//  Copyright © 2016 Drewag. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

public class TemplateBuilder {
    private(set) var values = TemplateValues()

    public subscript(key: String) -> String? {
        get {
            return self.values.string(forKey: key)
        }

        set {
            self.values.set(string: newValue, forKey: key)
        }
    }

    public func buildValues<ArrayElement>(forKey key: String, withArray array: [ArrayElement], build: (ArrayElement, TemplateBuilder) -> ()) {
        let valuesList = array.map { (element: ArrayElement) -> TemplateValues in
            let builder = TemplateBuilder()
            build(element, builder)
            return builder.values
        }
        self.values.set(values: valuesList, forKey: key)
    }
}