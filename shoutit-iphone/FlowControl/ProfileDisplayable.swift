//
//  ProfileDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol ProfileDisplayable {
    func showProfile(profile: Profile) -> Void
}

extension ProfileDisplayable where Self: FlowController, Self: ProfileCollectionViewControllerFlowDelegate {
    
    func showProfile(profile: Profile) {
        
        let controller = Wireframe.profileViewController()
        controller.flowDelegate = self
        controller.viewModel = ProfileCollectionViewModel(profile: profile)
        
        navigationController.navigationBarHidden = true
        navigationController.showViewController(controller, sender: nil)
    }
}
