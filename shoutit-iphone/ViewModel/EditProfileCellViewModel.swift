//
//  EditProfileCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum EditProfileCellViewModel {
    case Name(value: String)
    case Username(value: String)
    case Bio(value: String)
    case Location(value: Address)
    case Website(value: String)
    
    var reuseIdentifier: String {
        switch self {
        case .Name, .Username, .Website: return "EditProfileTextFieldCell"
        case .Bio: return "EditProfileTextViewCell"
        case .Location: return "EditProfileSelectButtonCell"
        }
    }
    
    var placeholderText: String? {
        switch self {
        case .Name:
            return NSLocalizedString("Name", comment: "Edit profile placeholder text")
        case .Username:
            return NSLocalizedString("Username", comment: "Edit profile placeholder text")
        case .Bio:
            return NSLocalizedString("Bio", comment: "Edit profile placeholder text")
        case .Website:
            return NSLocalizedString("Website", comment: "Edit profile placeholder text")
        default:
            return nil
        }
    }
}
