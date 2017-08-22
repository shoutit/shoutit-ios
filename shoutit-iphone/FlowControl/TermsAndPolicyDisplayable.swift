//
//  TermsAndPolicyDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol TermsAndPolicyDisplayable {
    func showRules() -> Void
    func showTermsAndConditions() -> Void
    func showPrivacyPolicy() -> Void
}

extension FlowController : TermsAndPolicyDisplayable {
    func showRules() {
        showHTMLControllerWithHTML(.Rules)
    }
    
    func showTermsAndConditions() {
        showHTMLControllerWithHTML(.TermsOfService)
    }
    
    func showPrivacyPolicy() {
        showHTMLControllerWithHTML(.Policy)
    }
    
    fileprivate func showHTMLControllerWithHTML(_ htmlFile: BundledHTMLFile) {
        let htmlController = Wireframe.htmlViewController()
        htmlController.htmlFile = htmlFile
        let navigationController = ModalNavigationController(rootViewController: htmlController)
        self.navigationController.present(navigationController, animated: true, completion: nil)
    }
}
