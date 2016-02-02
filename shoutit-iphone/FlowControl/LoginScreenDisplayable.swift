//
//  LoginScreenDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol LoginScreenDisplayable {
    func showLoginWithEmail() -> Void
}

extension LoginScreenDisplayable where Self: FlowController {
    
    func showLoginWithEmail() {
        let controller = Wireframe.loginWithEmailViewController()
        navigationController.showViewController(controller, sender: nil)
    }
}
