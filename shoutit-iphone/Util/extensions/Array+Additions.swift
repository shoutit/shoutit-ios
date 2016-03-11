//
//  Array+Additions.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension Array {
    func each(@noescape each: (Element) -> ()){
        for object: Element in self {
            each(object)
        }
    }
}

extension Array where Element:Equatable {
    func unique() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}