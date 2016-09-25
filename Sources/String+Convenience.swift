//
//  String+Convenience.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 7/4/16.
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

extension String {
    public func map(_ mapper: Mapper) -> IntermediateTransformer<IntermediateLevel1> {
        return IntermediateTransformer<IntermediateLevel1>(input: .string(self), mapper: mapper)
    }

    public func split(_ splitter: Splitter) -> IntermediateTransformer<IntermediateLevel2> {
        return IntermediateTransformer<IntermediateLevel2>(input: .string(self), splitter: splitter)
    }
}

extension Sequence where Iterator.Element: CustomStringConvertible {
    public func map(_ mapper: Mapper) -> IntermediateTransformer<IntermediateLevel2> {
        let array = self.map({$0.description})
        return IntermediateTransformer<IntermediateLevel2>(input: .array(array), mapper: mapper)
    }

    public func split(_ splitter: Splitter) -> IntermediateTransformer<IntermediateLevel3> {
        let array = self.map({$0.description})
        return IntermediateTransformer<IntermediateLevel3>(input: .array(array), splitter: splitter)
    }

    public func reduce(_ reducer: Reducer) -> IntermediateTransformer<IntermediateLevel1> {
        let array = self.map({$0.description})
        return IntermediateTransformer<IntermediateLevel1>(input: .array(array), reducer: reducer)
    }

    public func reduce(_ reducer: ConsolidatedReducer) -> IntermediateTransformer<IntermediateLevel1> {
        let array = self.map({$0.description})
        return IntermediateTransformer<IntermediateLevel1>(input: .array(array), reducer: reducer)
    }

    public func filter(_ filter: Filter) -> IntermediateTransformer<IntermediateLevel2> {
        let array = self.map({$0.description})
        return IntermediateTransformer<IntermediateLevel2>(input: .array(array), filter: filter)
    }

    public func filter(_ filter: ConsolidatedFilter) -> IntermediateTransformer<IntermediateLevel2> {
        let array = self.map({$0.description})
        return IntermediateTransformer<IntermediateLevel2>(input: .array(array), filter: filter)
    }
}
