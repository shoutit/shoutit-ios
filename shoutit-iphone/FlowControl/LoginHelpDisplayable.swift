//
//  LoginHelpDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol LoginHelpDisplayable {
    func showLoginHelp() -> Void
}

extension LoginHelpDisplayable where Self: FlowController {
    
    func showLoginHelp() -> Void {
        // show login screen
    }
}
