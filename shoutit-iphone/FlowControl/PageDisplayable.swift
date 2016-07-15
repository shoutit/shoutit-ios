//
//  PageDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol PageDisplayable {
    func showPage(page: Profile) -> Void
}

extension FlowController : PageDisplayable {
    
    func showPage(page: Profile) {
        
        let controller = Wireframe.profileViewController()
        controller.flowDelegate = self
        if case .Page(_, let userPage)? = Account.sharedInstance.loginState where userPage.id == page.id {
            controller.viewModel = MyPageCollectionViewModel()
        } else {
            controller.viewModel = PageProfileCollectionViewModel(profile: page)
        }
        navigationController.showViewController(controller, sender: nil)
    }
}
