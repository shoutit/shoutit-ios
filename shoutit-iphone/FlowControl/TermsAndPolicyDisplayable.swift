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

extension TermsAndPolicyDisplayable where Self: FlowController {
    
    func showRules() {
        showHTMLControllerWithHTML(.Rules)
    }
    
    func showTermsAndConditions() {
        showHTMLControllerWithHTML(.TermsOfService)
    }
    
    func showPrivacyPolicy() {
        showHTMLControllerWithHTML(.Policy)
    }
    
    private func showHTMLControllerWithHTML(htmlFile: BundledHTMLFile) {
        let htmlController = Wireframe.htmlViewController()
        htmlController.htmlFile = htmlFile
        let navigationController = ModalNavigationController(rootViewController: htmlController)
        self.navigationController.presentViewController(navigationController, animated: true, completion: nil)
    }
}
