//
//  EditProfileTableViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class EditProfileTableViewModel {
    
    let cells: [EditProfileCellViewModel]
    
    init() {
        precondition(Account.sharedInstance.loggedUser != nil)
        guard let user = Account.sharedInstance.loggedUser else {
            cells = []
            return
        }
        cells = [.Name(value: user.name),
                 .Username(value: user.username),
                 .Bio(value: user.bio),
                 .Location(value:user.location),
                 .Website(value: user.website ?? "")]
    }
}
