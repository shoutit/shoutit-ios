//
//  FlowController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD
import ShoutitKit

protocol UserAccess {
    func requiresLoggedInUser() -> Bool
}

class FlowController : UserAccess {
    var navigationController: UINavigationController
    var deepLink : DPLDeepLink?
    
    lazy var filterTransition: FilterTransition = {
        return FilterTransition()
    }()
    
    init(navigationController: UINavigationController, deepLink: DPLDeepLink? = nil) {
        self.navigationController = navigationController
        self.deepLink = deepLink
        handleDeeplink(deepLink)
    }
    
    func requiresLoggedInUser() -> Bool {
        return false
    }
    
    func handleDeeplink(_ deepLink: DPLDeepLink?) {
        
    }
}

protocol PartialChatDisplayable {
    func showConversationWithId(_ conversationId: String)
    func showProfileWithId(_ profileId: String)
    func showShoutWithId(_ shoutId: String)
}


extension FlowController : PartialChatDisplayable {
    func showConversationWithId(_ conversationId: String) {
        
        MBProgressHUD.showAdded(to: self.navigationController.visibleViewController?.view, animated: true)
        
        _ = APIChatsService.conversationWithId(conversationId).subscribe { (event) in
            
            MBProgressHUD.hideAllHUDs(for: self.navigationController.visibleViewController?.view, animated: true)
        
            if case .next(let conversation) = event {
                self.showConversation(.createdAndLoaded(conversation: conversation))
            }
        
        }
        
    }
    
    func showProfileWithId(_ profileId: String) {
        MBProgressHUD.showAdded(to: self.navigationController.visibleViewController?.view, animated: true)
        
        _ = APIProfileService.retrieveProfileWithUsername(profileId).subscribe { (event) in
            
            MBProgressHUD.hideAllHUDs(for: self.navigationController.visibleViewController?.view, animated: true)
            
            if case .next(let profile) = event {
                self.showProfile(Profile.profileWithUser(profile))
            }
            
        }
    }
    
    func showShoutWithId(_ shoutId: String) {
        MBProgressHUD.showAdded(to: self.navigationController.visibleViewController?.view, animated: true)
        
        _ = APIShoutsService.retrieveShoutWithId(shoutId).subscribe { (event) in
            
            MBProgressHUD.hideAllHUDs(for: self.navigationController.visibleViewController?.view, animated: true)
            
            if case .next(let shout) = event {
                self.showShout(shout)
            }
            
        }

    }
}
