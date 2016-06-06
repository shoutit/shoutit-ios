//
//  EditProfileCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum EditProfileCellViewModel {
    
    enum Identity {
        case Firstname
        case Lastname
        case Name
        case Username
        case Bio
        case Website
        case Mobile
        case Location
    }
    
    case BasicText(value: String, placeholder: String, identity: Identity)
    case RichText(value: String, placeholder: String, identity: Identity)
    case Location(value: Address, placeholder: String, identity: Identity)
    
    var reuseIdentifier: String {
        switch self {
        case .BasicText: return "EditProfileTextFieldCell"
        case .RichText: return "EditProfileTextViewCell"
        case .Location: return "EditProfileSelectButtonCell"
        }
    }
    
    var identity: Identity {
        switch self {
        case .BasicText(_, _, let identity):
            return identity
        case .RichText(_, _, let identity):
            return identity
        case .Location(_, _, let identity):
            return identity
        }
    }
    
    // MARK: - Conenience init
    
    init(firstname: String) {
        self = .BasicText(value: firstname, placeholder: NSLocalizedString("First name", comment: "Edit profile placeholder text"), identity: .Firstname)
    }
    
    init(lastname: String) {
        self = .BasicText(value: lastname, placeholder: NSLocalizedString("Last name", comment: "Edit profile placeholder text"), identity: .Lastname)
    }
    
    init(name: String) {
        self = .BasicText(value: name, placeholder: NSLocalizedString("Name", comment: "Edit profile placeholder text"), identity: .Name)
    }
    
    init(username: String) {
        self = .BasicText(value: username, placeholder: NSLocalizedString("Username", comment: "Edit profile placeholder text"), identity: .Username)
    }
    
    init(bio: String) {
        self = .RichText(value: bio, placeholder: NSLocalizedString("Bio", comment: "Edit profile placeholder text"), identity: .Bio)
    }
    
    init(website: String) {
        self = .BasicText(value: website, placeholder: NSLocalizedString("Website", comment: "Edit profile placeholder text"), identity: .Website)
    }
    
    init(location: Address) {
        self = .Location(value: location, placeholder: NSLocalizedString("Location", comment: "Edit profile placeholder text"), identity: .Location)
    }
    
    init(mobile: String) {
        self = .BasicText(value: mobile, placeholder: NSLocalizedString("Mobile", comment: "Edit profile placeholder text"), identity: .Mobile)
    }
}
