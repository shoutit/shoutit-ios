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

class LinkedAccountsManager : NSObject {
    
    private let account: Account
    
    private weak var presentingController : UIViewController?
    private weak var googleSettingsOption : SettingsOption?
    
    private let disposeBag = DisposeBag()
    
    init(account: Account) {
        self.account = account
    }
    
    func unlinkFacebookAlert(success: (Void -> Void)) -> UIAlertController {
        return unlinkAccountAlertWithTitle(NSLocalizedString("Do you want to unlink your Facebook account?", comment: ""), success: success)
    }
    
    func unlinkGoogleAlert(success: (Void -> Void)) -> UIAlertController {
        return unlinkAccountAlertWithTitle(NSLocalizedString("Do you want to unlink your Google account?", comment: ""), success: success)
    }
    
    private func unlinkAccountAlertWithTitle(title: String, success: (Void -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Unlink", comment: ""), style: .Destructive, handler: { (action) in
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
        }.addDisposableTo(disposeBag)
    }
    
    func linkFacebook(controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
        weak var wController = controller
        
        MBProgressHUD.showHUDAddedTo(controller.view, animated: true)
        
        Account.sharedInstance.facebookManager.linkWithReadPermissions(viewController: controller).subscribe { [weak self] (event) in
            guard let controller = wController else {
                return
            }
            
            MBProgressHUD.hideAllHUDsForView(controller.view, animated: true)
            
        }.addDisposableTo(disposeBag)

    }
    
    func linkGoogle(controller: UIViewController, disposeBag: DisposeBag, option: SettingsOption? = nil) {
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
        
        APIProfileService.unlinkSocialAccountWithParams(.Google(code: nil)).subscribe { [weak self] (event) in
            switch event {
            case .Next(_):
                self?.presentingController?.showSuccessMessage(NSLocalizedString("Google Account Unlinked", comment: ""))
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
            return
        }
        
        APIProfileService.linkSocialAccountWithParams(.Google(code: user.serverAuthCode)).subscribe { [weak self] (event) in
            switch event {
            case .Next(_):
                print("Google Connected")
                self?.presentingController?.showSuccessMessage(NSLocalizedString("Google Account Linked", comment: ""))
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
            return NSLocalizedString("Not Linked", comment: "")
        }
        
        if let _ = user.linkedAccounts?.facebook {
            return NSLocalizedString("Linked", comment: "")
        }
        
        return NSLocalizedString("Not Linked", comment: "")
    }
    
    func nameForGoogleAccount() -> String {
        guard let user = self.account.user as? DetailedProfile else {
            return NSLocalizedString("Not Linked", comment: "")
        }
        
        if let _ = user.linkedAccounts?.gplus {
            return NSLocalizedString("Linked", comment: "")
        }
        
        return NSLocalizedString("Not Linked", comment: "")
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

}
