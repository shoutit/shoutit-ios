//
//  CreateShoutCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum CreateShoutCellViewModel {    
    case Category
    case Description
    case Location
    case Mobile
    case FilterChoice(filter: Filter)
    case Facebook
}