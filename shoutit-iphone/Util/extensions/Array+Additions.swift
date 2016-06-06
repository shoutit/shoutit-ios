//
//  Array+Additions.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension Array {
    public func each(@noescape each: (Element) -> ()){
        for object: Element in self {
            each(object)
        }
    }
}

extension Array where Element: Equatable {
    public func unique() -> [Element] {
        return reduce([]) { (elements, element) -> [Element] in
            return elements.contains(element) ? elements : elements + [element]
        }
    }
    
    public mutating func removeElementIfExists(element: Element) {
        var indexToRemove: Int?
        for (index, value) in self.enumerate() {
            if element == value {
                indexToRemove = index
                break
            }
        }
        if let index = indexToRemove {
            self.removeAtIndex(index)
        }
    }
}

public extension SequenceType {
    
    /// Categorises elements of self into a dictionary, with the keys given by keyFunc
    public func categorise<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}