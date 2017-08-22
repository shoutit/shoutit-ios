//
//  Array+Additions.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension Array {
    public func each(_ each: (Element) -> ()){
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
    
    public mutating func removeElementIfExists(_ element: Element) {
        var indexToRemove: Int?
        for (index, value) in self.enumerated() {
            if element == value {
                indexToRemove = index
                break
            }
        }
        if let index = indexToRemove {
            self.remove(at: index)
        }
    }
}

public extension Sequence {
    
    /// Categorises elements of self into a dictionary, with the keys given by keyFunc
    public func categorise<U : Hashable>(_ keyFunc: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}
