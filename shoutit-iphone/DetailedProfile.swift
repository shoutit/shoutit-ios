//
//  DetailedProfileObject.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 11/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public protocol DetailedProfile : User {
    
    var webPath: String? { get }
    var name: String { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var isActivated: Bool { get }
    var imagePath: String? { get }
    var coverPath: String? { get }
    var isListening: Bool? { get }
    var about: String? { get }
    var mobile: String? { get }
}
