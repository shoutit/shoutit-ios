//
//  ProfileCollectionPageCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCollectionPageCellViewModel: ProfileCollectionCellViewModel {
    
    let profile: Profile
    
    init(profile: Profile) {
        self.profile = profile
    }
    
    func listeningCountString() -> String {
        let numberString = NumberFormatters.sharedInstance.numberToShortString(0)
        return NSLocalizedString("Listeners \(numberString)", comment: "")
    }
}
