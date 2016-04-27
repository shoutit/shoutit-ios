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

struct SettingsOption {
    let name: String
    let action: (Void -> Void)
}

final class SettingsFlowController: FlowController {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        
        // create initial view controller
        let controller = Wireframe.settingsViewController()
        controller.models = self.settingsOptions()
        navigationController.showViewController(controller, sender: nil)
    }
    
    func requiresLoggedInUser() -> Bool {
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
        return Variable([
            SettingsOption(name: NSLocalizedString("Email", comment: "Settings cell title")) {[unowned self] in
                self.showEmailSettings()
            },
            SettingsOption(name: NSLocalizedString("Password", comment: "Settings cell title")) {[unowned self] in
                self.showPasswordSettings()
            },
            SettingsOption(name: NSLocalizedString("Log out", comment: "Settings cell title")) {[unowned self] in
                
                do {
                    try Account.sharedInstance.logout()
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.UserDidLogoutNotification, object: nil)
                } catch let error {
                    self.navigationController.showError(error)
                }
            }
            ])
    }
}

extension SettingsFlowController: AboutDisplayable {}
extension SettingsFlowController: TermsAndPolicyDisplayable {}
