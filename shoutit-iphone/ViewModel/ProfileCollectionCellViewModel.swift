//
//  ProfileCollectionCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ProfileCollectionCellViewModelType {
    case Page
    case Shout
}

protocol ProfileCollectionCellViewModel {
    var type: ProfileCollectionCellViewModelType {get}
}
