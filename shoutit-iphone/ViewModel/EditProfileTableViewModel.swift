//
//  EditProfileTableViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class EditProfileTableViewModel {
    
    let user: LoggedUser
    var cells: [EditProfileCellViewModel]
    
    init() {
        precondition(Account.sharedInstance.loggedUser != nil)
        user = Account.sharedInstance.loggedUser!
        cells = [EditProfileCellViewModel(name: user.name),
                 EditProfileCellViewModel(username: user.username),
                 EditProfileCellViewModel(bio: user.bio),
                 EditProfileCellViewModel(location: user.location),
                 EditProfileCellViewModel(website: user.website ?? "")]
    }
    
    // MARK: - Mutation
    
    
}
