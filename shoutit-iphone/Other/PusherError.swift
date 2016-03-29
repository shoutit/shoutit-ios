//
//  PusherError.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum PusherError: ShoutitError {
    case WrongChannelName
    
    var userMessage: String {
        switch self {
        case .WrongChannelName:
            return NSLocalizedString("Could not subscribe to channel. Wrong Channel Name", comment: "")
        }
    }
}
