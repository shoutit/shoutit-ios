//
//  CreatePublicChatDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol CreatePublicChatDisplayable {
    func showCreatePublicChat() -> Void
}

extension FlowController : CreatePublicChatDisplayable {
    
    func showCreatePublicChat() {
        let controller = Wireframe.createPublicChatViewController()
        controller.viewModel = CreatePublicChatViewModel()
        let nav = ModalNavigationController(rootViewController: controller)
        navigationController.presentViewController(nav, animated: true, completion: nil)
    }
}
