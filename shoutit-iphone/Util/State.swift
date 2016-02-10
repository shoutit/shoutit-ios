//
//  State.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum LoadingState {
    case Idle
    case Loading
    case ContentLoaded
    case ContentUnavailable
    case Error(ErrorType)
}
