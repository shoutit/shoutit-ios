//
//  SelectProfileProfilesListEventHandler.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

class SelectProfileProfilesListEventHandler: ProfilesListEventHandler {
    
    var choiceHandler: ((Profile) -> Void)
    
    init(choiceHandler: ((Profile) -> Void)) {
        self.choiceHandler = choiceHandler
    }
    
    func handleUserDidTapProfile(_ profile: Profile) {
        choiceHandler(profile)
    }
}
