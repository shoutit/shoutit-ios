//
//  State.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum LoadingState {
    case idle
    case loading
    case contentLoaded
    case contentUnavailable
    case error(Error)
}
