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
    
    fileprivate let account: Account
    
    fileprivate weak var presentingController : UIViewController?
    fileprivate var googleSettingsOption : SettingsOption?
    
    fileprivate let disposeBag = DisposeBag()
    
    init(account: Account) {
        self.account = account
    }
    
    func unlinkFacebookAlert(_ success: @escaping ((Void) -> Void)) -> UIAlertController {
        return unlinkAccountAlertWithTitle(NSLocalizedString("Do you want to unlink your Facebook account?", comment: "Link Account Confirmation Message"), success: success)
    }
    
    func unlinkFacebookPageAlert(_ success: @escaping ((Void) -> Void)) -> UIAlertController {
        return unlinkAccountAlertWithTitle(NSLocalizedString("Do you want to unlink your Facebook Page account?", comment: "Link Account Confirmation Message"), success: success)
    }
    
    func unlinkGoogleAlert(_ success: @escaping ((Void) -> Void)) -> UIAlertController {
        return unlinkAccountAlertWithTitle(NSLocalizedString("Do you want to unlink your Google account?", comment: "Link Account Confirmation Message"), success: success)
    }
    
    fileprivate func unlinkAccountAlertWithTitle(_ title: String, success: @escaping ((Void) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Unlink", comment: "Link Account Confirmation Button"), style: .destructive, handler: { (action) in
            success()
        }))
        
        alert.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil))
        
        return alert
    }

    func unlinkFacebook(_ controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        weak var wController = controller
        
        MBProgressHUD.showAdded(to: controller.view, animated: true)
        
        Account.sharedInstance.facebookManager.unlinkFacebookAccount().subscribe { (event) in
            guard let controller = wController else {
                return
            }
            
            MBProgressHUD.hideAllHUDs(for: controller.view, animated: true)
            
            switch event {
            case .Error(let error): controller.showError(error)
            case .next (let success): controller.showSuccessMessage(success.message)
            default: break
            }
        }.addDisposableTo(disposeBag)
    }
    
    func linkFacebook(_ controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        weak var wController = controller
        
        MBProgressHUD.showAdded(to: controller.view, animated: true)
        
        Account.sharedInstance.facebookManager.linkWithReadPermissions(viewController: controller).subscribe { (event) in
            guard let controller = wController else {
                return
            }
            
            MBProgressHUD.hideAllHUDs(for: controller.view, animated: true)
            
            switch event {
            case .Error(let error): controller.showError(error)
            case .next (let success): controller.showSuccessMessage(success.message)
            default: break
            }
            
        }.addDisposableTo(disposeBag)

    }
    
    func linkGoogle(_ controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        GIDSignIn.sharedInstance().signOut()
        
        presentingController = controller
        
        googleSettingsOption = option
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func unlinkGoogle(_ controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        presentingController = controller
        
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance().signOut()
        
        googleSettingsOption = option
        
        APIProfileService.unlinkSocialAccountWithParams(.google(code: nil)).subscribe { [weak self] (event) in
            self?.googleSettingsOption?.detail = self?.nameForGoogleAccount()
            switch event {
            case .next(let success):
                Account.sharedInstance.fetchUserProfile()
                self?.presentingController?.showSuccessMessage(success.message)
            case .Error(let error):
                self?.presentingController?.showError(error)
                
            default: break
            }
            
            self?.presentingController = nil
        }.addDisposableTo(disposeBag)
        
    }
    
    func linkFacebookPage(_ controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        if !account.facebookManager.hasPermissions(.ManagePages) {
            account.facebookManager.requestManagePermissions([.ManagePages, .PublishPages], viewController: controller).subscribe { [weak self] (event) in
                switch event {
                case .next(_):
                    debugPrint("permissionsGranted")
                    self?.showPagesSelectionActionSheetFrom(controller, disposeBag: disposeBag, option: option)
                case .Error(LocalError.cancelled):
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
    
    func showPagesSelectionActionSheetFrom(_ controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        controller.showProgressHUD()
        
        let request = FBSDKGraphRequest(graphPath: "me/accounts", parameters: ["fields": "id, name"], httpMethod: "GET")
        
        request?.start {[weak self] (requestConnection, result, error) in
            controller.hideProgressHUD()
            
            if let error = error {
                controller.showError(error)
                return
            }
            
            if let result = result as? NSDictionary, let data = result["data"] as? [NSDictionary] {
                print(data)
                self?.presentPagesSelection(controller, disposeBag: disposeBag, option: option, pages: data)
            }
            
            
        }
    }
    
    func presentPagesSelection(_ controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil, pages: [NSDictionary]) {
        let alert = UIAlertController(title: NSLocalizedString("Please select a page:", comment: "Link Page Action Sheet"), message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil))
        
        for page in pages {
            guard let name = page["name"] as? String, let uid = page["id"] as? String else {
                continue
            }
            
            alert.addAction(UIAlertAction(title: name, style: .default, handler: { (action) in
                APIProfileService.linkFacebookPage(.facebookPage(pageId: uid)).subscribe { [weak self] (event) in
                    switch event {
                    case .next(let success):
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
        
        controller.present(alert, animated: true, completion: nil)
        
    }
    
    func unlinkFacebookPage(_ controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        presentingController = controller
        
        guard let user = self.account.user as? DetailedProfile, let pageId = user.linkedAccounts?.facebookPage?.facebookId else {
            return
        }
        
        APIProfileService.unlinkFacebookPage(.facebookPage(pageId: pageId)).subscribe { [weak self] (event) in
            switch event {
            case .next(_):
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
    @objc func signIn(_ signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
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
    
    @objc func signIn(_ signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
        presentingController = nil
        
    }
    
    func signIn(_ signIn: GIDSignIn!, presentViewController viewController: UIViewController!) {
        presentingController?.present(viewController, animated: true, completion: nil)
    }
    
    func signIn(_ signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
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
