//
//  ShoutDetailShoutImageViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum ShoutDetailShoutImageViewModel {
    case Image(url: NSURL)
    case NoContent(message: String)
    case Loading
    case Error(error: ErrorType)
}
