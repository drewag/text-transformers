//
//  String+Convenience.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 7/4/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

extension String {
    public func map(_ mapper: Mapper) -> IntermediateTransformer<IntermediateLevel1> {
        return IntermediateTransformer<IntermediateLevel1>(input: .string(self), mapper: mapper)
    }

    public func split(_ splitter: Splitter) -> IntermediateTransformer<IntermediateLevel2> {
        return IntermediateTransformer<IntermediateLevel2>(input: .string(self), splitter: splitter)
    }
}

extension String: CustomStringConvertible {
    public var description: String {
        return self
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