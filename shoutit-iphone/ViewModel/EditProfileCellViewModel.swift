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
    
    enum Identity  : Int {
        case firstname
        case lastname
        case name
        case username
        case bio
        case website
        case mobile
        case location
        case birthday
        case gender
    }
    
    case basicText(value: String, placeholder: String, identity: Identity)
    case richText(value: String, placeholder: String, identity: Identity)
    case location(value: Address, placeholder: String, identity: Identity)
    case date(value: Foundation.Date?, placeholder: String, identity: Identity)
    case gender(value: String?, placeholder: String, identity: Identity)
    
    var reuseIdentifier: String {
        switch self {
        case .basicText: return "EditProfileTextFieldCell"
        case .richText: return "EditProfileTextViewCell"
        case .location: return "EditProfileSelectButtonCell"
        case .gender: return "EditProfileSelectButtonCell"
        case .date: return "EditProfileDateTextFieldCell"
        }
    }
    
    var identity: Identity {
        switch self {
        case .basicText(_, _, let identity):
            return identity
        case .richText(_, _, let identity):
            return identity
        case .location(_, _, let identity):
            return identity
        case .date(_, _, let identity):
            return identity
        case .gender(_, _, let identity):
            return identity
        }
    }
    
    // MARK: - Conenience init
    
    init(firstname: String) {
        self = .basicText(value: firstname, placeholder: NSLocalizedString("First name", comment: "Edit profile placeholder text"), identity: .firstname)
    }
    
    init(lastname: String) {
        self = .basicText(value: lastname, placeholder: NSLocalizedString("Last name", comment: "Edit profile placeholder text"), identity: .lastname)
    }
    
    init(name: String) {
        self = .basicText(value: name, placeholder: NSLocalizedString("Name", comment: "Edit profile placeholder text"), identity: .name)
    }
    
    init(username: String) {
        self = .basicText(value: username, placeholder: NSLocalizedString("Username", comment: "Edit profile placeholder text"), identity: .username)
    }
    
    init(bio: String) {
        self = .richText(value: bio, placeholder: NSLocalizedString("Bio", comment: "Edit profile placeholder text"), identity: .bio)
    }
    
    init(website: String) {
        self = .basicText(value: website, placeholder: NSLocalizedString("Website", comment: "Edit profile placeholder text"), identity: .website)
    }
    
    init(location: Address) {
        self = .location(value: location, placeholder: NSLocalizedString("Location", comment: "Edit profile placeholder text"), identity: .location)
    }
    
    init(mobile: String) {
        self = .basicText(value: mobile, placeholder: NSLocalizedString("Mobile", comment: "Edit profile placeholder text"), identity: .mobile)
    }
    
    init(birthday: Foundation.Date?) {
        self = .date(value: birthday, placeholder: NSLocalizedString("Birthday", comment: "Edit profile placeholder text"), identity: .birthday)
    }
    
    init(gender: String) {
        self = .gender(value: gender, placeholder: NSLocalizedString("Gender", comment: "Edit profile placeholder text"), identity: .gender)
    }
}
