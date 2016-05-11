//
//  PagedResults.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct PagedResults<T: Decodable where T.DecodedType == T> {
    let count: Int?
    let previousPath: String?
    let nextPath: String?
    let results: [T]
}

extension PagedResults: Decodable {
    
    static func decode(j: JSON) -> Decoded<PagedResults<T>> {
        let a = curry(PagedResults<T>.init)
            <^> j <|? "count"
            <*> j <|? "previous"
        let b = a
            <*> j <|? "next"
            <*> j <|| "results"
        return b
    }
}

extension PagedResults {
    
    func beforeParamsString() -> String? {
        
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
