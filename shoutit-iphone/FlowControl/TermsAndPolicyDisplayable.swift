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
        
    }
    
    func showPrivacyPolicy() {
        
    }
}
