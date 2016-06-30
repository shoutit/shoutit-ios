//
//  SettingsFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 04/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD
import ShoutitKit

struct SettingsOption {
    let name: String
    let action: (Void -> Void)
}

final class SettingsFlowController: FlowController {
    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.settingsViewController()
        controller.models = self.settingsOptions()
        navigationController.showViewController(controller, sender: nil)
    }
    
    override func requiresLoggedInUser() -> Bool {
        return true
    }
    
    private func showAccountSettings() {
        let controller = Wireframe.settingsViewController()
        controller.models = self.accountSettingsOptions()
        controller.title = NSLocalizedString("Account", comment: "")
        controller.ignoreMenuButton = true
        navigationController.showViewController(controller, sender: nil)
    }
    
    private func showNotificationsSettings() {
        if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(settingsURL)
        }
    }
    
    private func showEmailSettings() {
        let controller = Wireframe.settingsFromViewController()
        controller.viewModel = ChangeEmailSettingsFormViewModel()
        controller.ignoreMenuButton = true
        navigationController.showViewController(controller, sender: nil)
    }
    
    private func showPasswordSettings() {
        let controller = Wireframe.settingsFromViewController()
        controller.viewModel = ChangePasswordSettingsFormViewModel()
        controller.ignoreMenuButton = true
        navigationController.showViewController(controller, sender: nil)
    }
    
    private func showLinkedAccountsSettings() {
        let controller = Wireframe.settingsViewController()
        controller.models = self.linkedAccountsOptions()
        controller.title = NSLocalizedString("Linked Accounts", comment: "")
        controller.ignoreMenuButton = true
        navigationController.showViewController(controller, sender: nil)
    }
    
    private func showFacebookLinked() {
        
    }
    
    private func showFacebookPageLinked() {
        
    }
    
    private func showGoogleLinked() {
        
    }
    
    private func settingsOptions() -> Variable<[SettingsOption]> {
        return Variable([
            SettingsOption(name: NSLocalizedString("Account", comment: "Settings cell title")) {[unowned self] in
                self.showAccountSettings()
            },
            SettingsOption(name: NSLocalizedString("Notification", comment: "Settings cell title")) {[unowned self] in
                self.showNotificationsSettings()
            },
            SettingsOption(name: NSLocalizedString("About", comment: "Settings cell title")) {[unowned self] in
                self.showAboutInterface()
            }
            ])
    }
    
    private func accountSettingsOptions() -> Variable<[SettingsOption]> {
        var options : [SettingsOption] = []
        
        
        options.append(SettingsOption(name: NSLocalizedString("Email", comment: "Settings cell title")) {[unowned self] in
            self.showEmailSettings()
        })
        

        options.append(SettingsOption(name: NSLocalizedString("Linked Accounts", comment: "Settings cell title")) {[unowned self] in
            self.showLinkedAccountsSettings()
        })
        
        options.append(SettingsOption(name: NSLocalizedString("Log out", comment: "Settings cell title")) {[unowned self] in
                
                do {
                    try Account.sharedInstance.logout()
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.UserDidLogoutNotification, object: nil)
                } catch let error {
                    self.navigationController.showError(error)
                }
        })
        
        if case .Logged(_)? = Account.sharedInstance.loginState {
            options.insert(SettingsOption(name: NSLocalizedString("Password", comment: "Settings cell title")) {[unowned self] in
                    self.showPasswordSettings()
            }, atIndex: 1)
        }
        
        return Variable(options)
    }
    
    private func linkedAccountsOptions() -> Variable<[SettingsOption]> {
        return Variable([
            SettingsOption(name: NSLocalizedString("Facebook", comment: "Settings cell title")) {[unowned self] in
                self.showFacebookLinked()
            },
            SettingsOption(name: NSLocalizedString("Facebook Page", comment: "Settings cell title")) {[unowned self] in
                self.showFacebookPageLinked()
            },
            SettingsOption(name: NSLocalizedString("Google", comment: "Settings cell title")) {[unowned self] in
                self.showGoogleLinked()
            }
            ])
    }
}
