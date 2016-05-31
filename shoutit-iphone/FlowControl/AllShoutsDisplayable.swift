//
//  ShoutsDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol AllShoutsDisplayable {
    func showShoutsForProfile(profile: Profile) -> Void
    func showRelatedShoutsForShout(shout: Shout) -> Void
    func showShoutsForTag(tag: Tag) -> Void
    func showShoutsForDiscoverItem(discoverItem: DiscoverItem) -> Void
    func showShoutsForConversation(conversation: Conversation) -> Void
}

extension FlowController : AllShoutsDisplayable {
    
    func showShoutsForProfile(profile: Profile) {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .ProfileShouts(user: profile)))
    }
    
    func showRelatedShoutsForShout(shout: Shout) {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .RelatedShouts(shout: shout)))
    }
    
    func showShoutsForTag(tag: Tag) -> Void {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .TagShouts(tag: tag)))
    }
    
    func showShoutsForDiscoverItem(discoverItem: DiscoverItem) {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .DiscoverItemShouts(discoverItem: discoverItem)))
    }
    
    func showShoutsForConversation(conversation: Conversation) {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .ConversationShouts(conversation: conversation)))
    }
    
    private func showShoutsWithViewModel(viewModel: ShoutsCollectionViewModel) {
        let controller = Wireframe.allShoutsCollectionViewController()
        controller.viewModel = viewModel
        controller.flowDelegate = self
        navigationController.showViewController(controller, sender: nil)
    }
}
