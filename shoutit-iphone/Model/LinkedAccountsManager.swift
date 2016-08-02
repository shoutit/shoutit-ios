//
//  Account+LinkedAccounts.swift
//  shoutit
//
//  Created by Piotr Bernad on 04/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit
import MBProgressHUD
import RxSwift
import FBSDKCoreKit

class LinkedAccountsManager : NSObject {
    
    private let account: Account
    
    private weak var presentingController : UIViewController?
    private var googleSettingsOption : SettingsOption?
    
    private let disposeBag = DisposeBag()
    
    init(account: Account) {
        self.account = account
    }
    
    func unlinkFacebookAlert(success: (Void -> Void)) -> UIAlertController {
        return unlinkAccountAlertWithTitle(NSLocalizedString("Do you want to unlink your Facebook account?", comment: "Link Account Confirmation Message"), success: success)
    }
    
    func unlinkFacebookPageAlert(success: (Void -> Void)) -> UIAlertController {
        return unlinkAccountAlertWithTitle(NSLocalizedString("Do you want to unlink your Facebook Page account?", comment: "Link Account Confirmation Message"), success: success)
    }
    
    func unlinkGoogleAlert(success: (Void -> Void)) -> UIAlertController {
        return unlinkAccountAlertWithTitle(NSLocalizedString("Do you want to unlink your Google account?", comment: "Link Account Confirmation Message"), success: success)
    }
    
    private func unlinkAccountAlertWithTitle(title: String, success: (Void -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Unlink", comment: "Link Account Confirmation Button"), style: .Destructive, handler: { (action) in
            success()
        }))
        
        alert.addAction(UIAlertAction(title: LocalizedString.cancel, style: .Cancel, handler: nil))
        
        return alert
    }

    func unlinkFacebook(controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        weak var wController = controller
        
        MBProgressHUD.showHUDAddedTo(controller.view, animated: true)
        
        Account.sharedInstance.facebookManager.unlinkFacebookAccount().subscribe { [weak self] (event) in
            guard let controller = wController else {
                return
            }
            
            MBProgressHUD.hideAllHUDsForView(controller.view, animated: true)
            
            switch event {
            case .Error(let error): controller.showError(error)
            case .Next (let success): controller.showSuccessMessage(success.message)
            default: break
            }
        }.addDisposableTo(disposeBag)
    }
    
    func linkFacebook(controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        weak var wController = controller
        
        MBProgressHUD.showHUDAddedTo(controller.view, animated: true)
        
        Account.sharedInstance.facebookManager.linkWithReadPermissions(viewController: controller).subscribe { (event) in
            guard let controller = wController else {
                return
            }
            
            MBProgressHUD.hideAllHUDsForView(controller.view, animated: true)
            
            switch event {
            case .Error(let error): controller.showError(error)
            case .Next (let success): controller.showSuccessMessage(success.message)
            default: break
            }
            
        }.addDisposableTo(disposeBag)

    }
    
    func linkGoogle(controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        GIDSignIn.sharedInstance().signOut()
        
        presentingController = controller
        
        googleSettingsOption = option
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func unlinkGoogle(controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        presentingController = controller
        
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance().signOut()
        
        googleSettingsOption = option
        
        APIProfileService.unlinkSocialAccountWithParams(.Google(code: nil)).subscribe { [weak self] (event) in
            self?.googleSettingsOption?.detail = self?.nameForGoogleAccount()
            switch event {
            case .Next(let success):
                Account.sharedInstance.fetchUserProfile()
                self?.presentingController?.showSuccessMessage(success.message)
            case .Error(let error):
                self?.presentingController?.showError(error)
                
            default: break
            }
            
            self?.presentingController = nil
        }.addDisposableTo(disposeBag)
        
    }
    
    func linkFacebookPage(controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        if !account.facebookManager.hasPermissions(.ManagePages) {
            account.facebookManager.requestManagePermissions([.ManagePages, .PublishPages], viewController: controller).subscribe { [weak self] (event) in
                switch event {
                case .Next(_):
                    debugPrint("permissionsGranted")
                    self?.showPagesSelectionActionSheetFrom(controller, disposeBag: disposeBag, option: option)
                case .Error(LocalError.Cancelled):
                    break
                case .Error(let error):
                    controller.showError(error)
                default:
                    break
                }
                }.addDisposableTo(disposeBag)
            return
        }
        
        self.showPagesSelectionActionSheetFrom(controller, disposeBag: disposeBag, option: option)
    }
    
    func showPagesSelectionActionSheetFrom(controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        controller.showProgressHUD()
        
        let request = FBSDKGraphRequest(graphPath: "me/accounts", parameters: ["fields": "id, name"], HTTPMethod: "GET")
        
        request.startWithCompletionHandler {[weak self] (requestConnection, result, error) in
            controller.hideProgressHUD()
            
            if let error = error {
                controller.showError(error)
                return
            }
            
            if let result = result as? NSDictionary, data = result["data"] as? [NSDictionary] {
                print(data)
                self?.presentPagesSelection(controller, disposeBag: disposeBag, option: option, pages: data)
            }
            
            
        }
    }
    
    func presentPagesSelection(controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil, pages: [NSDictionary]) {
        let alert = UIAlertController(title: NSLocalizedString("Please select a page:", comment: "Link Page Action Sheet"), message: nil, preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: LocalizedString.cancel, style: .Cancel, handler: nil))
        
        for page in pages {
            guard let name = page["name"] as? String, uid = page["id"] as? String else {
                continue
            }
            
            alert.addAction(UIAlertAction(title: name, style: .Default, handler: { (action) in
                APIProfileService.linkFacebookPage(.FacebookPage(pageId: uid)).subscribe { [weak self] (event) in
                    switch event {
                    case .Next(let success):
                        Account.sharedInstance.fetchUserProfile()
                        controller.showSuccessMessage(success.message)
                    case .Error(let error):
                        controller.showError(error)
                    default: break
                    }
                    
                    self?.presentingController = nil
                }.addDisposableTo(disposeBag)
            }))
            
        }
        
        controller.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func unlinkFacebookPage(controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        presentingController = controller
        
        guard let user = self.account.user as? DetailedProfile, pageId = user.linkedAccounts?.facebookPage?.facebookId else {
            return
        }
        
        APIProfileService.unlinkFacebookPage(.FacebookPage(pageId: pageId)).subscribe { [weak self] (event) in
            switch event {
            case .Next(_):
                Account.sharedInstance.fetchUserProfile()
                self?.presentingController?.showSuccessMessage(NSLocalizedString("Facebook Page Unlinked", comment: "UnLink Page Message"))
            case .Error(let error):
                self?.presentingController?.showError(error)
                
            default: break
            }
            
            self?.presentingController = nil
        }.addDisposableTo(disposeBag)
    }
}

extension LinkedAccountsManager : GIDSignInDelegate, GIDSignInUIDelegate {
    @objc func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
        if error != nil {
            self.presentingController?.showError(error)
            return
        }
        
        APIProfileService.linkSocialAccountWithParams(.Google(code: user.serverAuthCode)).subscribe { [weak self] (event) in
            switch event {
            case .Next(let success):
                self?.presentingController?.showSuccessMessage(success.message)
                self?.googleSettingsOption?.detail = self?.nameForGoogleAccount()
                Account.sharedInstance.fetchUserProfile()
            case .Error(let error):
                self?.presentingController?.showError(error)
            
            default: break
            }
        
            self?.presentingController = nil
        }.addDisposableTo(disposeBag)
        
        
        
    }
    
    @objc func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
        presentingController = nil
        
    }
    
    func signIn(signIn: GIDSignIn!, presentViewController viewController: UIViewController!) {
        presentingController?.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }

}

// Helpers
extension LinkedAccountsManager {
    func nameForFacebookAccount() -> String {
        guard let user = self.account.user as? DetailedProfile else {
            return LocalizedString.notLinked
        }
        
        if let _ = user.linkedAccounts?.facebook {
            return LocalizedString.linked
        }
        
        return LocalizedString.notLinked
    }
    
    func nameForFacebookPageAccount() -> String {
        guard let user = self.account.user as? DetailedProfile else {
            return LocalizedString.notLinked
        }
        
        if let page = user.linkedAccounts?.facebookPage {
            return page.name
        }
        
        return LocalizedString.notLinked
    }
    
    func nameForGoogleAccount() -> String {
        guard let user = self.account.user as? DetailedProfile else {
            return LocalizedString.notLinked
        }
        
        if let _ = user.linkedAccounts?.gplus {
            return LocalizedString.linked
        }
        
        return LocalizedString.notLinked
    }
    
    func isFacebookLinked() -> Bool {
        guard let user = self.account.user as? DetailedProfile else {
            return false
        }
        
        if let _ = user.linkedAccounts?.facebook {
            return true
        }
        
        return false
    }
    
    func isGoogleLinked() -> Bool {
        guard let user = self.account.user as? DetailedProfile else {
            return false
        }
        
        if let _ = user.linkedAccounts?.gplus {
            return true
        }
        
        return false
    }
    
    func isFacebookPageLinked() -> Bool {
        guard let user = self.account.user as? DetailedProfile else {
            return false
        }
        
        if let _ = user.linkedAccounts?.facebookPage {
            return true
        }
        
        return false
    }

}
