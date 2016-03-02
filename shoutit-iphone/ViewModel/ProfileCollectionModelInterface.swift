//
//  ProfileCollectionModelInterface.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol ProfileCollectionUser {
    var name: String {get}
    var username: String {get}
    var imagePath: String? {get}
    var coverPath: String? {get}
    var listenersCount: Int {get}
    var listeningMetadata: ListenersMetadata? {get}
    var bio: String {get}
    var website: String? {get}
    var dateJoinedEpoch_optional: Int? {get}
    var location_optional: Address? {get}
    var pages: [Profile]? {get}
}