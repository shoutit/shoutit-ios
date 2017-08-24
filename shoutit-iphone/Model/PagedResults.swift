//
//  PagedResults.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct PagedResults<T: JSONCodable> {
    public let count: Int?
    public let previousPath: String?
    public let nextPath: String?
    public let results: [T]
    
    public init(count: Int?, previousPath: String?, nextPath: String?, results: [T]) {
        self.count = count
        self.previousPath = previousPath
        self.nextPath = nextPath
        self.results = results
    }
}

extension PagedResults: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        count = try decoder.decode("count")
        previousPath = try decoder.decode("previous")
        nextPath = try decoder.decode("next")
        results = try decoder.decode("results")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(results, key: "results")
        })
    }
}

extension PagedResults {
    
    public init(_ results: [T]) {
        self.results = results
        self.count = results.count
        self.previousPath = nil
        self.nextPath = nil
    }
}

extension PagedResults {
    
    public func beforeParamsString() -> String? {
        
        guard let next = previousPath else {
            return nil
        }
        
        if let range : Range<String.Index> = next.range(of: "?before=") {
            
            let paramsRange : Range<String.Index> = range.lowerBound..<next.endIndex
            let params = next.substring(with: paramsRange)
            
            return params
        }
        
        return nil
    }
}
