//
//  SocialActionError.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum SocialActionError: ShoutitError {
    case FacebookPermissionsFailedError
    
    var userMessage: String {
        switch self {
        case .FacebookPermissionsFailedError:
            return NSLocalizedString("Failed to obtain facebook publish permissions", comment: "Returned when updating permissions scope fails on API side")
        }
    }
}
