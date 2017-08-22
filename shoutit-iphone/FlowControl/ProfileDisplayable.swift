//
//  ProfileDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol ProfileDisplayable {
    func showProfile(_ profile: Profile) -> Void
}

extension FlowController : ProfileDisplayable {
    
    func showProfile(_ profile: Profile) {
        
        let controller = Wireframe.profileViewController()
        controller.flowDelegate = self
        if case .logged(let user)? = Account.sharedInstance.loginState, user.id == profile.id {
            controller.viewModel = MyProfileCollectionViewModel()
        } else if case .some(.page(let _, let page)) = Account.sharedInstance.loginState, page.id == profile.id {
            controller.viewModel = MyPageCollectionViewModel()
        } else {
            controller.viewModel = UserProfileCollectionViewModel(profile: profile)
        }
        
        navigationController.show(controller, sender: nil)
    }
}
