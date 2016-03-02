//
//  ShoutsDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol AllShoutsDisplayable {
    func showShoutsForUsername(username: String) -> Void
}

extension AllShoutsDisplayable where Self: FlowController {
    
    func showShoutsForUsername(username: String) {
        navigationController.notImplemented()
    }
}
