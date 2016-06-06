//
//  PostSignupInterestCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

final class PostSignupInterestCellViewModel {
    
    let category: ShoutitKit.Category
    var selected: Bool = false
    
    init(category: ShoutitKit.Category) {
        self.category = category
    }
}
