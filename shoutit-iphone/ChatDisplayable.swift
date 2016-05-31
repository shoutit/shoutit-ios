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
    func showConversation(conversation: ConversationViewModel.ConversationExistance) -> Void
    func showConversationInfo(conversation: Conversation) -> Void
    func showAttachmentControllerWithTransitioningDelegate(transitionDelegate: UIViewControllerTransitioningDelegate?, completion: ((type: PickerAttachmentType) -> Void)) -> Void
    func showLocation(coordinate: CLLocationCoordinate2D) -> Void
    func showImagePreview(imageURL: NSURL) -> Void
    func showVideoPreview(videoURL: NSURL) -> Void
    func startVideoCallWithProfile(profile: Profile) -> Void
    func showVideoConversation(conversation: TWCConversation) -> Void
}

extension FlowController : ChatDisplayable {
    
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
    
    func showConversationInfo(conversation: Conversation) -> Void {
        let controller = Wireframe.conversationInfoController()
        controller.viewModel = ConversationInfoViewModel(conversation: conversation)
        controller.flowDelegate = self
        self.navigationController.showViewController(controller, sender: nil)
    }
    
    func showAttachmentControllerWithTransitioningDelegate(transitionDelegate: UIViewControllerTransitioningDelegate? = nil, completion: ((type: PickerAttachmentType) -> Void)) -> Void {
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
        let controller = PhotoBrowser(photos: [MWPhoto(URL: imageURL)])
        
        self.navigationController.showViewController(controller, sender: nil)
    }
    
    func showVideoPreview(videoURL: NSURL) -> Void {
        let controller = PhotoBrowser(photos: [MWPhoto(videoURL: videoURL)])
        
        self.navigationController.showViewController(controller, sender: nil)
    }
    
    func startVideoCallWithProfile(profile: Profile) -> Void {
        let controller = Wireframe.videoCallController()
        
        controller.callingToProfile = profile
        
        self.navigationController.presentViewController(controller, animated: true, completion: nil)
    }
    
    func showVideoConversation(conversation: TWCConversation) -> Void {
        let controller = Wireframe.videoCallController()
        
        controller.conversation = conversation
        
        self.navigationController.presentViewController(controller, animated: true, completion: nil)
    }
}

extension MWPhotoBrowser {
    override func prefersTabbarHidden() -> Bool {
        return true
    }
}
