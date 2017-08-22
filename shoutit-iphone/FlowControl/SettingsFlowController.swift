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

class SettingsOption {
    let name: String
    let action: ((SettingsOption) -> Void)
    var detail: String?
    var refresh: ((SettingsOption) -> Void)?
    
    init(name: String, action: @escaping ((SettingsOption) -> Void), detail: String? = nil) {
        self.name = name
        self.action = action
        self.detail = detail
    }
 
}

final class SettingsFlowController: FlowController {
    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.settingsViewController()
        controller.models = self.settingsOptions()
        navigationController.show(controller, sender: nil)
    }
    
    override func requiresLoggedInUser() -> Bool {
        return true
    }
    
    fileprivate func showAccountSettings() {
        let controller = Wireframe.settingsViewController()
        controller.models = self.accountSettingsOptions()
        controller.title = NSLocalizedString("Account", comment: "")
        controller.ignoreMenuButton = true
        navigationController.show(controller, sender: nil)
    }
    
    fileprivate func showNotificationsSettings() {
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(settingsURL)
        }
    }
    
    fileprivate func showEmailSettings() {
        let controller = Wireframe.settingsFromViewController()
        controller.viewModel = ChangeEmailSettingsFormViewModel()
        controller.ignoreMenuButton = true
        navigationController.show(controller, sender: nil)
    }
    
    fileprivate func showPasswordSettings() {
        let controller = Wireframe.settingsFromViewController()
        controller.viewModel = ChangePasswordSettingsFormViewModel()
        controller.ignoreMenuButton = true
        navigationController.show(controller, sender: nil)
    }
    
    fileprivate func showLinkedAccountsSettings() {
        let controller = Wireframe.settingsViewController()
        controller.models = self.linkedAccountsOptions()
        controller.title = NSLocalizedString("Linked Accounts", comment: "")
        controller.ignoreMenuButton = true
        navigationController.show(controller, sender: nil)
    }
    
    fileprivate func settingsOptions() -> Variable<[SettingsOption]> {
        return Variable([
            SettingsOption(name: NSLocalizedString("Account", comment: "Settings cell title"), action: {[unowned self] (option) in
                self.showAccountSettings()
            }),
            SettingsOption(name: NSLocalizedString("Notification", comment: "Settings cell title"), action: {[unowned self] (option) in
                self.showNotificationsSettings()
            }),
            SettingsOption(name: NSLocalizedString("About", comment: "Settings cell title"), action: {[unowned self] (option) in
                self.showAboutInterface()
            })
            ])
    }
    
    fileprivate func accountSettingsOptions() -> Variable<[SettingsOption]> {
        var options : [SettingsOption] = []
        
        
        options.append(SettingsOption(name: NSLocalizedString("Email", comment: "Settings cell title"), action: {[unowned self] (option) in
            self.showEmailSettings()
        }))
        

        options.append(SettingsOption(name: NSLocalizedString("Linked Accounts", comment: "Settings cell title"), action: {[unowned self] (option) in
            self.showLinkedAccountsSettings()
        }))
        
        options.append(SettingsOption(name: NSLocalizedString("Log out", comment: "Settings cell title"), action: {[unowned self] (option) in
                
                do {
                    try Account.sharedInstance.logout()
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Constants.Notification.UserDidLogoutNotification), object: nil)
                } catch let error {
                    self.navigationController.showError(error)
                }
        }))
        
        if case .logged(_)? = Account.sharedInstance.loginState {
            options.insert(SettingsOption(name: NSLocalizedString("Password", comment: "Settings cell title"), action: {[unowned self] (option) in
                    self.showPasswordSettings()
            }), at: 1)
        }
        
        return Variable(options)
    }
    
    fileprivate func linkedAccountsOptions() -> Variable<[SettingsOption]> {
        let facebookOption = SettingsOption(name: NSLocalizedString("Facebook", comment: "Settings cell title"), action: {[unowned self] (option) in
            let manager  = Account.sharedInstance.linkedAccountsManager
            
            guard let controller = self.navigationController.visibleViewController as? SettingsTableViewController else {
                return
            }
            
            if manager.isFacebookLinked() {
                let alert = manager.unlinkFacebookAlert({
                    
                    manager.unlinkFacebook(controller, disposeBag: controller.disposeBag)
                })
                
                self.navigationController.present(alert, animated: true, completion: nil)
            } else {
                Account.sharedInstance.linkedAccountsManager.linkFacebook(controller, disposeBag: controller.disposeBag, option: option)
            }
            }, detail: Account.sharedInstance.linkedAccountsManager.nameForFacebookAccount())
        
        let googleOption = SettingsOption(name: NSLocalizedString("Google", comment: "Settings cell title"), action: {[unowned self] (option) in
            let manager  = Account.sharedInstance.linkedAccountsManager
            
            guard let controller = self.navigationController.visibleViewController as? SettingsTableViewController else {
                return
            }
            
            if manager.isGoogleLinked() {
                let alert = manager.unlinkGoogleAlert({
                    
                    manager.unlinkGoogle(controller, disposeBag: controller.disposeBag, option: option)
                })
                
                self.navigationController.present(alert, animated: true, completion: nil)
            } else {
                manager.linkGoogle(controller, disposeBag: controller.disposeBag)
            }
            }, detail: Account.sharedInstance.linkedAccountsManager.nameForGoogleAccount())
        
        let facebookPageOption = SettingsOption(name: NSLocalizedString("Facebook Page", comment: ""), action: { (option) in
            let manager  = Account.sharedInstance.linkedAccountsManager
            
            guard let controller = self.navigationController.visibleViewController as? SettingsTableViewController else {
                return
            }
            
            if manager.isFacebookPageLinked() {
                let alert = manager.unlinkFacebookPageAlert({
                    
                    manager.unlinkFacebookPage(controller, disposeBag: controller.disposeBag)
                })
                
                self.navigationController.present(alert, animated: true, completion: nil)
            } else {
                manager.linkFacebookPage(controller, disposeBag: controller.disposeBag)
            }
            
        }, detail: Account.sharedInstance.linkedAccountsManager.nameForFacebookPageAccount())
        
        facebookPageOption.refresh = { (option) in
            option.detail = Account.sharedInstance.linkedAccountsManager.nameForFacebookPageAccount()
        }
        
        facebookOption.refresh = { (option) in
            option.detail = Account.sharedInstance.linkedAccountsManager.nameForFacebookAccount()
        }
        
        googleOption.refresh = { (option) in
            option.detail = Account.sharedInstance.linkedAccountsManager.nameForGoogleAccount()
        }
        
            return Variable([ facebookOption, googleOption, facebookPageOption])
        }
}
