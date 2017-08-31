//
//  ChatDisplayable.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

typealias AttachmentCompletion = ((_ type: PickerAttachmentType) -> Void)

protocol ChatDisplayable {
    func showConversation(_ conversation: ConversationViewModel.ConversationExistance) -> Void
    func showConversationInfo(_ conversation: Conversation) -> Void
    func showAttachmentControllerWithTransitioningDelegate(_ transitionDelegate: UIViewControllerTransitioningDelegate?, completion: @escaping AttachmentCompletion) -> Void
    func showLocation(_ coordinate: CLLocationCoordinate2D) -> Void
    func showImagePreview(_ imageURL: URL) -> Void
    func showVideoPreview(_ videoURL: URL, thumbnailURL: URL) -> Void
    func startVideoCallWithProfile(_ profile: Profile) -> Void
}

extension FlowController : ChatDisplayable {
    
    func showConversation(_ conversation: ConversationViewModel.ConversationExistance) {
        let controller = Wireframe.conversationController()
        
        controller.flowDelegate = self
        controller.viewModel = ConversationViewModel(conversation: conversation, delegate: controller)
        
        // if there was conversation pop instead of adding another controller to stack
        let previousControllersCount = (self.navigationController.viewControllers.count - 2)
        
        if previousControllersCount >= 0 {
            if let conversationController = self.navigationController.viewControllers[previousControllersCount] as? ConversationViewController, let conversationId = conversationController.viewModel.conversation.value.conversationId {
                
                if conversationId == conversation.conversationId {
                    self.navigationController.popToViewController(conversationController, animated: true)
                    return
                }
            }
        }
        
        self.navigationController.show(controller, sender: nil)
    }
    
    func showConversationInfo(_ conversation: Conversation) -> Void {
        let controller = Wireframe.conversationInfoController()
        controller.viewModel = ConversationInfoViewModel(conversation: conversation)
        controller.flowDelegate = self
        self.navigationController.show(controller, sender: nil)
    }
    
    func showAttachmentControllerWithTransitioningDelegate(_ transitionDelegate: UIViewControllerTransitioningDelegate?, completion: @escaping AttachmentCompletion) {
        let controller = Wireframe.conversationAttachmentController()
        
        controller.completion = completion
        controller.transitioningDelegate = transitionDelegate
        controller.modalPresentationStyle = .custom
        
        self.navigationController.present(controller, animated: true, completion: nil)
    }
    
    func showLocation(_ coordinate: CLLocationCoordinate2D) -> Void {
        let controller = Wireframe.conversationLocationController()
        
        controller.coordinates = coordinate
        
        self.navigationController.show(controller, sender: nil)
    }
    
    func showImagePreview(_ imageURL: URL) -> Void {
        guard let controller = PhotoBrowser(photos: [MWPhoto(url: imageURL)]) else { return }
        
        self.navigationController.show(controller, sender: nil)
    }
    
    func showVideoPreview(_ videoURL: URL, thumbnailURL: URL) -> Void {
        guard let controller = PhotoBrowser(photos: [MWPhoto(videoURL: videoURL, thumbnailURL: thumbnailURL)]) else { return }
        
        self.navigationController.show(controller, sender: nil)
    }
    
    func startVideoCallWithProfile(_ profile: Profile) -> Void {
        let controller = Wireframe.videoCallController()
        controller.viewModel = VideoCallViewModel(callerProfile: profile)
        self.navigationController.present(controller, animated: true, completion: nil)
    }
}

extension MWPhotoBrowser {
    override func prefersTabbarHidden() -> Bool {
        return true
    }
}
