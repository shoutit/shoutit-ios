//
//  UnwrapOperators.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

infix operator !! {}

func !! <T>(wrapped: T?, @autoclosure failureText: () -> String) -> T {
    if let x = wrapped {return x}
    fatalError(failureText)
}

infix operator !? {}

func !? <T>(wrapped: T?, @autoclosure nilDefault: () -> (value: T, text: String)) -> T {
    assert(wrapped != nil, nilDefault().text)
    return wrapped ?? nilDefault().value
}


