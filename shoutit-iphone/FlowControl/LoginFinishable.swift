//
//  LoginFinishable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol LoginFinishable {
    func didFinishLoginProcessWithSuccess(_ success: Bool) -> Void
}

extension LoginFlowController : LoginFinishable {
    
    func didFinishLoginProcessWithSuccess(_ success: Bool) {
        if let loginFinishedBlock = loginFinishedBlock {
            loginFinishedBlock(success)
        } else {
            navigationController.dismiss(animated: true, completion: nil)
        }
    }
}
