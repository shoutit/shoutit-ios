//
//  User.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct User {
    
    // basic info
    private(set) var id: String = ""
    private(set) var username: String = ""
    private(set) var email: String = ""
    private(set) var name: String = ""
    private(set) var firstName: String = ""
    private(set) var lastName: String = ""
    
    // urls
    private(set) var apiPath: String = ""
    private(set) var webPath: String = ""
    
    // images
    private(set) var image: String = ""
    
    // additional info
    private(set) var gender: String = ""
    private(set) var bio: String = ""
    private(set) var location: Address = Address()
    private(set) var isActivated: Bool = false

    // followers
    private(set) var isListening: Bool = false
    private(set) var linkedAccounts: LoginAccounts = LoginAccounts()
    private(set) var isFollowing: Bool = false
    private(set) var listenersCount: Int = 0
    private(set) var listeningCount: ListenersMetadata = ListenersMetadata()
    
    // computed properties
    var apiURL: NSURL? {
        return NSURL(string: apiPath)
    }
    
    var webURL: NSURL? {
        return NSURL(string: webPath)
    }
}

extension User: BasicMappable {
    
    mutating func sequence(map: Map) throws {
        try apiPath              <~> map["api_url"]
        try webPath              <~> map["web_url"]
        try username            <~> map["username"]
        try bio                 <~> map["bio"]
        try id                  <~> map["id"]
        try location            <~> map["location"]
        try name                <~> map["name"]
        try firstName           <~> map["first_name"]
        try lastName            <~> map["last_name"]
        try isActivated         <~> map["is_activated"]
        try image               <~> map["image"]
        try isListening         <~> map["is_listening"]
        try isFollowing         <~> map["is_following"]
        try email               <~> map["email"]
        try gender              <~> map["gender"]
        try linkedAccounts      <~> map["linked_accounts"]
        try listenersCount      <~> map["listeners_count"]
        try listeningCount      <~> map["listening_count"]
    }
}
