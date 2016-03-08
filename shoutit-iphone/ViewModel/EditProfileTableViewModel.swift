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
        self.cells = [.Name(value: ""), .Username(value: ""), .Bio(value: ""), .Location(value:Account.sharedInstance.loggedUser!.location), .Website(value: "")]
    }
}
