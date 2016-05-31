//
//  CreateShoutDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol CreateShoutDisplayable {
    func showCreateShout() -> Void
}

extension FlowController : CreateShoutDisplayable {
    
    func showCreateShout() {
        navigationController.notImplemented()
    }
}