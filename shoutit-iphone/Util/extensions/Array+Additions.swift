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

extension Array {
    static func filterNils(array: [Element?]) -> [Element] {
        return array.filter { $0 != nil }.map { $0! }
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
    
    mutating func removeElementIfExists(element: Element) {
        var indexToRemove: Int?
        for (index, value) in self.enumerate() {
            if element == value {
                indexToRemove = index
            }
        }
        if let index = indexToRemove {
            self.removeAtIndex(index)
        }
    }
}

public extension SequenceType {
    
    /// Categorises elements of self into a dictionary, with the keys given by keyFunc
    func categorise<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}