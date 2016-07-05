//
//  IntermediateTransformer.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 7/4/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

public protocol IntermediateLevel {}

enum IntermediateInputType {
    case string(String)
    case array([String])
}

public struct IntermediateTransformer<Level: IntermediateLevel>: ComboTransformer {
    public let pipeline: [TransformPipe]
    private let input: IntermediateInputType

    init(input: IntermediateInputType, splitter: Splitter) {
        self.input = input
        self.pipeline = [.split(splitter)]
    }

    init(input: IntermediateInputType, mapper: Mapper) {
        self.input = input
        self.pipeline = [.map(mapper)]
    }

    init(input: IntermediateInputType, reducer: Reducer) {
        self.input = input
        self.pipeline = [.reduce(reducer)]
    }

    init(input: IntermediateInputType, reducer: ConsolidatedReducer) {
        self.input = input
        self.pipeline = [.consolidatedReduce(reducer)]
    }

    init(input: IntermediateInputType, filter: Filter) {
        self.input = input
        self.pipeline = [.filter(filter)]
    }

    init(input: IntermediateInputType, filter: ConsolidatedFilter) {
        self.input = input
        self.pipeline = [.consolidatedFilter(filter)]
    }

    private init(pipeline: [TransformPipe], input: IntermediateInputType) {
        self.input = input
        self.pipeline = pipeline
    }
}

extension IntermediateTransformer where Level: IntermediateLowLevel {
    public func split(_ splitter: Splitter) -> IntermediateTransformer<Level.UpLevel> {
        return IntermediateTransformer<Level.UpLevel>(pipeline: self.pipeline + [.split(splitter)], input: self.input)
    }

    public func map(_ mapper: Mapper) -> IntermediateTransformer<Level> {
        return IntermediateTransformer<Level>(pipeline: self.pipeline + [.map(mapper)], input: self.input)
    }

    public func map(_ function: (String) -> (String)) -> IntermediateTransformer<Level> {
        let mapper = FunctionMapper(function)
        return self.map(mapper)
    }
}

extension IntermediateTransformer where Level: IntermediateStringLevel {
    public func string() throws -> String {
        let intermediate: Intermediate = try self.apply(input: self.input)
        return intermediate.allValues.first ?? ""
    }
}

extension IntermediateTransformer where Level: IntermediateArrayLevel {
    public func array() throws -> [String] {
        let intermediate: Intermediate = try self.apply(input: self.input)
        return intermediate.allValues
    }
}

extension IntermediateTransformer where Level: IntermediateHighLevel {
    public func reduce(_ reducer: Reducer) -> IntermediateTransformer<Level.DownLevel> {
        return IntermediateTransformer<Level.DownLevel>(pipeline: self.pipeline + [.reduce(reducer)], input: self.input)
    }

    public func reduce(_ reducer: ConsolidatedReducer) -> IntermediateTransformer<Level.DownLevel> {
        return IntermediateTransformer<Level.DownLevel>(pipeline: self.pipeline + [.consolidatedReduce(reducer)], input: self.input)
    }

    public func filter(_ function: (String) -> Bool) -> IntermediateTransformer<Level> {
        let filter = FunctionFilter(function)
        return self.filter(filter)
    }

    public func filter(_ filter: Filter) -> IntermediateTransformer<Level> {
        return IntermediateTransformer<Level>(pipeline: self.pipeline + [.filter(filter)], input: self.input)
    }

    public func filter(_ filter: ConsolidatedFilter) -> IntermediateTransformer<Level> {
        return IntermediateTransformer<Level>(pipeline: self.pipeline + [.consolidatedFilter(filter)], input: self.input)
    }
}

public protocol IntermediateLowLevel: IntermediateLevel { associatedtype UpLevel: IntermediateLevel }
public protocol IntermediateStringLevel: IntermediateLowLevel {}
public protocol IntermediateHighLevel: IntermediateLevel { associatedtype DownLevel: IntermediateLevel }
public protocol IntermediateTopLevel: IntermediateHighLevel {}
public protocol IntermediateMidLevel: IntermediateLowLevel, IntermediateHighLevel {}
public protocol IntermediateArrayLevel: IntermediateMidLevel {}

public struct IntermediateLevel1: IntermediateStringLevel { public typealias UpLevel = IntermediateLevel2 }
public struct IntermediateLevel2: IntermediateArrayLevel { public typealias DownLevel = IntermediateLevel1; public typealias UpLevel = IntermediateLevel3 }
public struct IntermediateLevel3: IntermediateMidLevel { public typealias DownLevel = IntermediateLevel2; public typealias UpLevel = IntermediateLevel4 }
public struct IntermediateLevel4: IntermediateMidLevel { public typealias DownLevel = IntermediateLevel3; public typealias UpLevel = IntermediateLevel5 }
public struct IntermediateLevel5: IntermediateMidLevel { public typealias DownLevel = IntermediateLevel4; public typealias UpLevel = IntermediateLevel6 }
public struct IntermediateLevel6: IntermediateMidLevel { public typealias DownLevel = IntermediateLevel5; public typealias UpLevel = IntermediateLevel7 }
public struct IntermediateLevel7: IntermediateMidLevel { public typealias DownLevel = IntermediateLevel6; public typealias UpLevel = IntermediateLevel8 }
public struct IntermediateLevel8: IntermediateMidLevel { public typealias DownLevel = IntermediateLevel7; public typealias UpLevel = IntermediateLevel9 }
public struct IntermediateLevel9: IntermediateTopLevel { public typealias DownLevel = IntermediateLevel8 }