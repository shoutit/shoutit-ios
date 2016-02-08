//
//  PublicProfile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol PublicProfile {
    
    // public profile
    var id: String {get}
    var type: UserType {get}
    var apiPath: String {get}
    var webPath: String {get}
    var username: String? {get}
    var name: String? {get}
    var firstName: String? {get}
    var lastName: String? {get}
    var activated: Bool {get}
    var imagePath: String? {get}
    var coverPath: String? {get}
    var gender: Gender? {get}
    var videoPath: String? {get}
    var dateJoindedEpoch: Int {get}
    var bio: String? {get}
    var location: Address {get}
    var email: String {get}
    var website: String? {get}
    var shoutsPath: String? {get}
    var listenersCount: Int {get}
    var listenersPath: String? {get}
    var listeningMetadata: ListenersMetadata {get}
    var listeningPath: String? {get}
    var owner: Bool {get}
    var pages: [User]? {get}
}

enum UserType: String {
    case Profile = "Profile"
    case Page = "Page"
}

enum Gender: String {
    
    init?(string: String?) {
        if let string = string {
            self.init(rawValue: string)!
        } else {
            self.init(rawValue: "unknown")
        }
    }
    
    case Unknown = "unknown"
    case Male = "male"
    case Female = "female"
}