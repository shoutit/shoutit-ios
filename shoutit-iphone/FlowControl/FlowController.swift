//
//  FlowController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import DeepLinkKit
import RxSwift
import MBProgressHUD

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
    
    func handleDeeplink(deepLink: DPLDeepLink?) {
        
    }
}

protocol PartialChatDisplayable {
    func showConversationWithId(conversationId: String)
    func showProfileWithId(profileId: String)
    func showShoutWithId(shoutId: String)
}


extension FlowController : PartialChatDisplayable {
    func showConversationWithId(conversationId: String) {
        
        MBProgressHUD.showHUDAddedTo(self.navigationController.visibleViewController?.view, animated: true)
        
        _ = APIChatsService.conversationWithId(conversationId).subscribe { (event) in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController.visibleViewController?.view, animated: true)
        
            if case .Next(let conversation) = event {
                self.showConversation(.CreatedAndLoaded(conversation: conversation))
            }
        
        }
        
    }
    
    func showProfileWithId(profileId: String) {
        MBProgressHUD.showHUDAddedTo(self.navigationController.visibleViewController?.view, animated: true)
        
        _ = APIProfileService.retrieveProfileWithUsername(profileId).subscribe { (event) in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController.visibleViewController?.view, animated: true)
            
            if case .Next(let profile) = event {
                self.showProfile(Profile.profileWithUser(profile))
            }
            
        }
    }
    
    func showShoutWithId(shoutId: String) {
        MBProgressHUD.showHUDAddedTo(self.navigationController.visibleViewController?.view, animated: true)
        
        _ = APIShoutsService.retrieveShoutWithId(shoutId).subscribe { (event) in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController.visibleViewController?.view, animated: true)
            
            if case .Next(let shout) = event {
                self.showShout(shout)
            }
            
        }

    }
}