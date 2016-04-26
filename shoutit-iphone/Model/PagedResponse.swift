//
//  MessagesResponse.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct PagedResponse<T: Decodable where T.DecodedType == T>: Decodable {
    var results: [T]
    var next: String?
    var previous: String?
    
    static func decode(j: JSON) -> Decoded<PagedResponse<T>> {
        let a = curry(PagedResponse.init)
            <^> j <|| "results"
            <*> j <|? "next"
            <*> j <|? "previous"
        return a
    }
    
    func beforeParamsString() -> String? {
        print(self.next)
        
        guard let next = self.previous else {
            return nil
        }
        
        if let range : Range<String.Index> = next.rangeOfString("?before=") {
            
            let paramsRange : Range<String.Index> = Range(start: range.startIndex, end: next.endIndex)
            let params = next.substringWithRange(paramsRange)
            
            return params
        }
        
        return nil
        
    }
}
