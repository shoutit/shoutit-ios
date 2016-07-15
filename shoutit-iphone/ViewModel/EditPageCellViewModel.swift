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
        case Name
        case About
        case IsPublished
        case Description
        case Phone
        case Founded
        case Impressum
        case Overview
        case Mission
        case GeneralInfo
    }
    
    case BasicText(value: String, placeholder: String, identity: Identity)
    case RichText(value: String, placeholder: String, identity: Identity)
    case Location(value: Address, placeholder: String, identity: Identity)
    case Switch(value: Bool, placeholder: String, identity: Identity)
    
    var reuseIdentifier: String {
        switch self {
        case .BasicText: return "EditPageTextFieldCell"
        case .RichText: return "EditPageTextViewCell"
        case .Location: return "EditPageSelectButtonCell"
        case .Switch: return "EditPageSwitchTableViewCell"
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
        case .Switch(_, _, let identity):
            return identity
        }
    }
    
    // MARK: - Conenience init
    
    init(name: String) {
        self = .BasicText(value: name, placeholder: NSLocalizedString("Name", comment: "Edit page placeholder text"), identity: .Name)
    }
    
    init(about: String) {
        self = .RichText(value: about, placeholder: NSLocalizedString("About", comment: "Edit page placeholder text"), identity: .About)
    }
    
    init(description: String) {
        self = .RichText(value: description, placeholder: NSLocalizedString("Description", comment: "Edit page placeholder text"), identity: .Description)
    }
    
    init(phone: String) {
        self = .BasicText(value: phone, placeholder: NSLocalizedString("Phone", comment: "Edit page placeholder text"), identity: .Phone)
    }
    
    init(founded: String) {
        self = .BasicText(value: founded, placeholder: NSLocalizedString("Founded", comment: "Edit page placeholder text"), identity: .Founded)
    }
    
    init(impressum: String) {
        self = .RichText(value: impressum, placeholder: NSLocalizedString("Impressum", comment: "Edit page placeholder text"), identity: .Impressum)
    }
    
    init(overview: String) {
        self = .RichText(value: overview, placeholder: NSLocalizedString("Overview", comment: "Edit page placeholder text"), identity: .Overview)
    }
    
    init(mission: String) {
        self = .RichText(value: mission, placeholder: NSLocalizedString("Mission", comment: "Edit page placeholder text"), identity: .Mission)
    }
    
    init(general_info: String) {
        self = .RichText(value: general_info, placeholder: NSLocalizedString("General Info", comment: "Edit page placeholder text"), identity: .GeneralInfo)
    }
    
    init(published: Bool) {
        self = .Switch(value: published, placeholder: NSLocalizedString("Published", comment: ""), identity: .IsPublished)
    }
    
}
