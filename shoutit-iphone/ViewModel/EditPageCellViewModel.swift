//
//  EditPageCellViewModel.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 08/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum EditPageCellViewModel {
    
    enum Identity  : Int {
        case name
        case about
        case isPublished
        case description
        case phone
        case founded
        case impressum
        case overview
        case mission
        case generalInfo
    }
    
    case basicText(value: String, placeholder: String, identity: Identity)
    case richText(value: String, placeholder: String, identity: Identity)
    case location(value: Address, placeholder: String, identity: Identity)
    case `switch`(value: Bool, placeholder: String, identity: Identity)
    
    var reuseIdentifier: String {
        switch self {
        case .basicText: return "EditPageTextFieldCell"
        case .richText: return "EditPageTextViewCell"
        case .location: return "EditPageSelectButtonCell"
        case .switch: return "EditPageSwitchTableViewCell"
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
        case .switch(_, _, let identity):
            return identity
        }
    }
    
    // MARK: - Conenience init
    
    init(name: String) {
        self = .basicText(value: name, placeholder: NSLocalizedString("Name", comment: "Edit page placeholder text"), identity: .name)
    }
    
    init(about: String) {
        self = .richText(value: about, placeholder: NSLocalizedString("About", comment: "Edit page placeholder text"), identity: .about)
    }
    
    init(description: String) {
        self = .richText(value: description, placeholder: NSLocalizedString("Description", comment: "Edit page placeholder text"), identity: .description)
    }
    
    init(phone: String) {
        self = .basicText(value: phone, placeholder: NSLocalizedString("Phone", comment: "Edit page placeholder text"), identity: .phone)
    }
    
    init(founded: String) {
        self = .basicText(value: founded, placeholder: NSLocalizedString("Founded", comment: "Edit page placeholder text"), identity: .founded)
    }
    
    init(impressum: String) {
        self = .richText(value: impressum, placeholder: NSLocalizedString("Impressum", comment: "Edit page placeholder text"), identity: .impressum)
    }
    
    init(overview: String) {
        self = .richText(value: overview, placeholder: NSLocalizedString("Overview", comment: "Edit page placeholder text"), identity: .overview)
    }
    
    init(mission: String) {
        self = .richText(value: mission, placeholder: NSLocalizedString("Mission", comment: "Edit page placeholder text"), identity: .mission)
    }
    
    init(general_info: String) {
        self = .richText(value: general_info, placeholder: NSLocalizedString("General Info", comment: "Edit page placeholder text"), identity: .generalInfo)
    }
    
    init(published: Bool) {
        self = .switch(value: published, placeholder: NSLocalizedString("Published", comment: "Edit Page placeholder"), identity: .isPublished)
    }
    
}
