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
    let cells: [EditProfileCellViewModel]
    
    init() {
        precondition(Account.sharedInstance.loggedUser != nil)
        user = Account.sharedInstance.loggedUser!
        cells = [.Name(value: user.name),
                 .Username(value: user.username),
                 .Bio(value: user.bio),
                 .Location(value:user.location),
                 .Website(value: user.website ?? "")]
    }
    
    // MARK: - Convenience methods
    
    func locationTuple() -> (String, UIImage?)? {
        let locationViewModel = cells.filter { (cellViewModel) -> Bool in
            if case EditProfileCellViewModel.Location = cellViewModel {
                return true
            }
            return false
        }.first
        
        guard case EditProfileCellViewModel.Location(let location)? = locationViewModel else { return nil }
        
        let locationString = "\(location.city), \(location.country)"
        let flag = UIImage(named: location.country)
        
        return (locationString, flag)
    }
}
