//
//  MediaDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol MediaDisplayable {
    func showMediaForConversation(conversation: Conversation) -> Void
}

extension FlowController : MediaDisplayable {
    
    func showMediaForConversation(conversation: Conversation) {
        let viewModel = MessageAttachmentPhotoBrowserViewModel(conversation: conversation)
        let controller = MessageAttachmentPhotoBrowserViewController(delegate: viewModel)
        controller.viewModel = viewModel
        navigationController.showViewController(controller, sender: nil)
    }
}
