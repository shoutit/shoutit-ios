//
//  FlowController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import DeepLinkKit

protocol UserAccess {
    func requiresLoggedInUser() -> Bool
}

extension FlowController {
    func requiresLoggedInUser() -> Bool {
        return false
    }
}

protocol FlowController : UserAccess {
    var navigationController: UINavigationController {get}
    var deepLink : DPLDeepLink? { get set }
}

protocol PartialChatDisplayable {
    func showConversationWithId(conversationId: String)
}

extension FlowController where Self : PartialChatDisplayable {
    func showConversationWithId(conversationId: String) {
        self.navigationController.showViewController(<#T##vc: UIViewController##UIViewController#>, sender: <#T##AnyObject?#>)
    }
    
    
    func showConversation(conversation: ConversationViewModel.ConversationExistance) {
        let controller = Wireframe.conversationController()
        
        controller.flowDelegate = self
        controller.viewModel = ConversationViewModel(conversation: conversation, delegate: controller)
        
        // if there was conversation pop instead of adding another controller to stack
        let previousControllersCount = (self.navigationController.viewControllers.count - 2)
        
        if previousControllersCount >= 0 {
            if let conversation = self.navigationController.viewControllers[previousControllersCount] as? ConversationViewController {
                self.navigationController.popToViewController(conversation, animated: true)
                return
            }
        }
        
        self.navigationController.showViewController(controller, sender: nil)
    }
}

