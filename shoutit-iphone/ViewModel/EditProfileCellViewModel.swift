//
//  EditProfileCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum EditProfileCellViewModel {
    case BasicText(value: String, placeholder: String)
    case RichText(value: String, placeholder: String)
    case Location(value: Address, placeholder: String)
    
    var reuseIdentifier: String {
        switch self {
        case .BasicText: return "EditProfileTextFieldCell"
        case .RichText: return "EditProfileTextViewCell"
        case .Location: return "EditProfileSelectButtonCell"
        }
    }
    
    // MARK: - Conenience init
    
    init(name: String) {
        self = .BasicText(value: name, placeholder: NSLocalizedString("Name", comment: "Edit profile placeholder text"))
    }
    
    init(username: String) {
        self = .BasicText(value: username, placeholder: NSLocalizedString("Username", comment: "Edit profile placeholder text"))
    }
    
    init(bio: String) {
        self = .RichText(value: bio, placeholder: NSLocalizedString("Bio", comment: "Edit profile placeholder text"))
    }
    
    init(website: String) {
        self = .BasicText(value: website, placeholder: NSLocalizedString("Website", comment: "Edit profile placeholder text"))
    }
    
    init(location: Address) {
        self = .Location(value: location, placeholder: NSLocalizedString("Location", comment: "Edit profile placeholder text"))
    }
}
