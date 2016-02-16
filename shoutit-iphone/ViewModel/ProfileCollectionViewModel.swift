//
//  ProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileCollectionViewModel {
    
    let user: User
    
    private(set) var pages: [ProfileCollectionPageCellViewModel] = []
    private(set) var shouts: [ProfileCollectionShoutCellViewModel] = []
    
    init(user: User) {
        self.user = user
    }
    
    
}
