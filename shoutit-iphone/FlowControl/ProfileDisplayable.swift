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
        if profile.id == Account.sharedInstance.user?.id {
            controller.viewModel = MyProfileCollectionViewModel()
        } else {
            controller.viewModel = UserProfileCollectionViewModel(profile: profile)
        }
        
        navigationController.navigationBarHidden = true
        navigationController.showViewController(controller, sender: nil)
    }
}
