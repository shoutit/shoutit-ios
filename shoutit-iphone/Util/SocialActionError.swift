//
//  SocialActionError.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum SocialActionError: ShoutitError {
    case facebookPermissionsFailedError
    
    var userMessage: String {
        switch self {
        case .facebookPermissionsFailedError:
            return NSLocalizedString("Failed to obtain facebook publish permissions", comment: "Returned when updating permissions scope fails on API side")
        }
    }
}
