//
//  PostSignupInterestCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class PostSignupInterestCellViewModel {
    
    let category: Category
    var selected: Bool = false
    
    init(category: Category) {
        self.category = category
    }
}
