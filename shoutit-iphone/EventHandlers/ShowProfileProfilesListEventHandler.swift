//
//  ShowProfileProfilesListEventHandler.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

final class ShowProfileProfilesListEventHandler: ProfilesListEventHandler {
    
    let profileDisplayable: ProfileDisplayable
    
    init(profileDisplayable: ProfileDisplayable) {
        self.profileDisplayable = profileDisplayable
    }
    
    func handleUserDidTapProfile(profile: Profile) {
        profileDisplayable.showProfile(profile)
    }
}
