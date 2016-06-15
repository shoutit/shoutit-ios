//
//  ProfilesListEventHandler.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol ProfilesListEventHandler: class {
    func handleUserDidTapProfile(profile: Profile)
}
