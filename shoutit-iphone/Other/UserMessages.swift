//
//  UserMessages.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum UserMessages {
    
    static func startedListeningMessageWithName(name: String) -> String {
        return NSLocalizedString("You have successully started listening to \(name)", comment: "")
    }
    
    static func stoppedListeningMessageWithName(name: String) -> String {
        return NSLocalizedString("You have successully stopped listening to \(name)", comment: "")
    }
}
