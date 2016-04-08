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
}

extension AllShoutsDisplayable where Self: FlowController, Self: ShoutsCollectionViewControllerFlowDelegate {
    
    func showShoutsForProfile(profile: Profile) {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .ProfileShouts(user: profile)))
    }
    
    func showRelatedShoutsForShout(shout: Shout) {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .RelatedShouts(shout: shout)))
    }
    
    func showShoutsForTag(tag: Tag) -> Void {
        showShoutsWithViewModel(ShoutsCollectionViewModel(context: .TagShouts(tag: tag)))
    }
    
    private func showShoutsWithViewModel(viewModel: ShoutsCollectionViewModel) {
        let controller = Wireframe.allShoutsCollectionViewController()
        controller.viewModel = viewModel
        controller.flowDelegate = self
        navigationController.showViewController(controller, sender: nil)
    }
}
