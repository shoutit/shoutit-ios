//
//  AboutDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

protocol AboutDisplayable: class {
    func showAboutInterface() -> Void
}

extension AboutDisplayable where Self: FlowController, Self: TermsAndPolicyDisplayable {
    
    func showAboutInterface() {
        let aboutViewController = Wireframe.settingsViewController()
        aboutViewController.models = aboutOptions()
        navigationController.showViewController(aboutViewController, sender: nil)
    }
    
    private func aboutOptions() -> Variable<[SettingsOption]> {
        return Variable([
            SettingsOption(name: NSLocalizedString("Terms of Service", comment: "Settings cell title")) {[unowned self] in
                self.showTermsAndConditions()
            },
            SettingsOption(name: NSLocalizedString("Privacy Policy", comment: "Settings cell title")) {[unowned self] in
                self.showPrivacyPolicy()
            },
            SettingsOption(name: NSLocalizedString("Legal", comment: "Settings cell title")) {[unowned self] in
                self.showRules()
            }
            ])
    }
}
