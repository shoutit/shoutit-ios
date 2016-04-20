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
        return String.localizedStringWithFormat(NSLocalizedString("You have successfully started listening to %@", comment: ""), name)
    }
    
    static func stoppedListeningMessageWithName(name: String) -> String {
        return String.localizedStringWithFormat(NSLocalizedString("You have successfully stopped listening to %@", comment: ""), name)
    }
}
