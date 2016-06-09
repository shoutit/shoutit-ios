//
//  PagedResults.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo


public struct PagedResults<T: Decodable where T.DecodedType == T> {
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

extension PagedResults: Decodable {
    
    public static func decode(j: JSON) -> Decoded<PagedResults<T>> {
        let a = curry(PagedResults<T>.init)
            <^> j <|? "count"
            <*> j <|? "previous"
        let b = a
            <*> j <|? "next"
            <*> j <|| "results"
        return b
    }
    
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
        
        if let range : Range<String.Index> = next.rangeOfString("?before=") {
            
            let paramsRange : Range<String.Index> = range.startIndex..<next.endIndex
            let params = next.substringWithRange(paramsRange)
            
            return params
        }
        
        return nil
    }
}
