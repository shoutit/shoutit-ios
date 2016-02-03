//
//  Array+Additions.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

extension Array {
    func each(each: (Element) -> ()){
        for object: Element in self {
            each(object)
        }
    }
}