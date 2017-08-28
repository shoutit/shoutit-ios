//
//  MediaDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol MediaDisplayable {
    func showMediaForConversation(_ conversation: Conversation) -> Void
}

extension FlowController : MediaDisplayable {
    
    func showMediaForConversation(_ conversation: Conversation) {
        let viewModel = MessageAttachmentPhotoBrowserViewModel(conversation: conversation)
        guard let controller = MessageAttachmentPhotoBrowserViewController(delegate: viewModel) else { return }
        controller.viewModel = viewModel
        navigationController.show(controller, sender: nil)
    }
}
