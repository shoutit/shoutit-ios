//
//  CartDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol CartDisplayable {
    func showCart() -> Void
}

extension CartDisplayable where Self: FlowController {
    
    func showCart() {
        navigationController.notImplemented()
    }
}