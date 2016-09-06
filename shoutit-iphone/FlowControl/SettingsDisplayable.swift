//
//  SettingsDisplayable.swift
//  shoutit
//
//  Created by Piotr Bernad on 06/09/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

protocol SettingsDisplayable {
    func showSettings() -> Void
}

extension FlowController : SettingsDisplayable {
    func showSettings() {
        let controller = Wireframe.settingsViewController()
        controller.models = self.settingsOptions()
        
        self.navigationController.showViewController(controller, sender: nil)
    }
}

extension FlowController {
    
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
    
    private func settingsOptions() -> Variable<[SettingsOption]> {
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
    
    private func accountSettingsOptions() -> Variable<[SettingsOption]> {
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
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.UserDidLogoutNotification, object: nil)
            } catch let error {
                self.navigationController.showError(error)
            }
            }))
        
        if case .Logged(_)? = Account.sharedInstance.loginState {
            options.insert(SettingsOption(name: NSLocalizedString("Password", comment: "Settings cell title"), action: {[unowned self] (option) in
                self.showPasswordSettings()
                }), atIndex: 1)
        }
        
        return Variable(options)
    }
    
    private func linkedAccountsOptions() -> Variable<[SettingsOption]> {
        let facebookOption = SettingsOption(name: NSLocalizedString("Facebook", comment: "Settings cell title"), action: {[unowned self] (option) in
            let manager  = Account.sharedInstance.linkedAccountsManager
            
            guard let controller = self.navigationController.visibleViewController as? SettingsTableViewController else {
                return
            }
            
            if manager.isFacebookLinked() {
                let alert = manager.unlinkFacebookAlert({
                    
                    manager.unlinkFacebook(controller, disposeBag: controller.disposeBag)
                })
                
                self.navigationController.presentViewController(alert, animated: true, completion: nil)
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
                
                self.navigationController.presentViewController(alert, animated: true, completion: nil)
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
                
                self.navigationController.presentViewController(alert, animated: true, completion: nil)
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