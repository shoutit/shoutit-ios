//
//  CreateShoutCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum CreateShoutCellViewModel {    
    case category
    case description
    case location
    case mobile
    case filterChoice(filter: Filter)
    case facebook
}
