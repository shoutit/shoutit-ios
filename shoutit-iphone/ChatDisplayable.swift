//
//  ChatDisplayable.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import MWPhotoBrowser

protocol ChatDisplayable {
    func showConversation(conversation: Conversation) -> Void
    func showAttachmentController(completion: ((type: MessageAttachmentType) -> Void), transitionDelegate: UIViewControllerTransitioningDelegate?) -> Void
    func showLocation(coordinate: CLLocationCoordinate2D) -> Void
    func showImagePreview(imageURL: NSURL) -> Void
    func showVideoPreview(videoURL: NSURL) -> Void
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
    
    func showLocation(coordinate: CLLocationCoordinate2D) -> Void {
        let controller = Wireframe.conversationLocationController()
        
        controller.coordinates = coordinate
        
        self.navigationController.showViewController(controller, sender: nil)
    }
    
    func showImagePreview(imageURL: NSURL) -> Void {
        let controller = MWPhotoBrowser(photos: [MWPhoto(URL: imageURL)])
        
        self.navigationController.showViewController(controller, sender: nil)
    }
    
    func showVideoPreview(videoURL: NSURL) -> Void {
        let controller = MWPhotoBrowser(photos: [MWPhoto(videoURL: videoURL)])
        
        self.navigationController.showViewController(controller, sender: nil)
    }
}

extension MWPhotoBrowser {
    override func prefersTabbarHidden() -> Bool {
        return true
    }
}
