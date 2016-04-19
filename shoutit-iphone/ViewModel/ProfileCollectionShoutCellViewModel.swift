//
//  ProfileCollectionShoutCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ProfileCollectionShoutCellViewModel: ProfileCollectionCellViewModel {
    
    let shout: Shout
    
    init(shout: Shout) {
        self.shout = shout
    }
}
