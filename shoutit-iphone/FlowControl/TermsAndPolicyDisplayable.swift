//
//  TermsAndPolicyDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol TermsAndPolicyDisplayable {
    func showTermsAndConditions() -> Void
    func showPrivacyPolicy() -> Void
}

extension TermsAndPolicyDisplayable where Self: FlowController {
    
    func showTermsAndConditions() {
        
        let htmlController = Wireframe.htmlViewController()
        htmlController.htmlFile = .TermsOfService
        let navigationController = UINavigationController(rootViewController: htmlController)
        self.navigationController.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func showPrivacyPolicy() {
        
        let htmlController = Wireframe.htmlViewController()
        htmlController.htmlFile = .Policy
        let navigationController = UINavigationController(rootViewController: htmlController)
        self.navigationController.presentViewController(navigationController, animated: true, completion: nil)
    }
}
