//
//  FlowController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol UserAccess {
    func requiresLoggedInUser() -> Bool
}

extension FlowController {
    func requiresLoggedInUser() -> Bool {
        return false
    }
}

protocol FlowController : UserAccess{
    var navigationController: UINavigationController {get}
}
