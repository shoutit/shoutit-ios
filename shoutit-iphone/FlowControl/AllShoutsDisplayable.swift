//
//  ShoutsDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol AllShoutsDisplayable {
    func showShoutsForProfile(_ profile: Profile) -> Void
    func showRelatedShoutsForShout(_ shout: Shout) -> Void
    func showShoutsForTag(_ tag: Tag) -> Void
    func showShoutsForDiscoverItem(_ discoverItem: DiscoverItem) -> Void
    func showShoutsForConversation(_ conversation: Conversation) -> Void
}

extension FlowController : AllShoutsDisplayable {
    
    func showShoutsForProfile(_ profile: Profile) {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .profileShouts(user: profile)))
    }
    
    func showRelatedShoutsForShout(_ shout: Shout) {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .relatedShouts(shout: shout)))
    }
    
    func showShoutsForTag(_ tag: Tag) -> Void {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .tagShouts(tag: tag)))
    }
    
    func showShoutsForDiscoverItem(_ discoverItem: DiscoverItem) {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .discoverItemShouts(discoverItem: discoverItem)))
    }
    
    func showShoutsForConversation(_ conversation: Conversation) {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .conversationShouts(conversation: conversation)))
    }
    
    fileprivate func showShoutsWithViewModel(_ viewModel: ShoutsCollectionViewModel) {
        let controller = Wireframe.allShoutsCollectionViewController()
        controller.viewModel = viewModel
        controller.flowDelegate = self
        navigationController.show(controller, sender: nil)
    }
}
