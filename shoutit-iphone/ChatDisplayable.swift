//
//  ChatDisplayable.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol ChatDisplayable {
    func showConversation(conversation: Conversation) -> Void
    func showAttachmentController(completion: ((type: MessageAttachmentType) -> Void), transitionDelegate: UIViewControllerTransitioningDelegate?) -> Void
}

extension ChatDisplayable where Self: FlowController, Self: ConversationListTableViewControllerFlowDelegate, Self: ConversationViewControllerFlowDelegate {
    
    func showConversation(conversation: Conversation) {
        let controller = Wireframe.conversationController()
        
        controller.flowDelegate = self
        controller.conversation = conversation
        
        self.navigationController.showViewController(controller, sender: nil)
    }
    
    func showAttachmentController(completion: ((type: MessageAttachmentType) -> Void), transitionDelegate: UIViewControllerTransitioningDelegate? = nil) -> Void {
        let controller = Wireframe.conversationAttachmentController()
        
        controller.completion = completion
        controller.transitioningDelegate = transitionDelegate
        controller.modalPresentationStyle = .Custom
        
        self.navigationController.presentViewController(controller, animated: true, completion: nil)
    }
}
