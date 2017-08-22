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
    func showPage(_ page: Profile) -> Void
}

extension FlowController : PageDisplayable {
    
    func showPage(_ page: Profile) {
        
        let controller = Wireframe.profileViewController()
        controller.flowDelegate = self
        if case .page(_, let userPage)? = Account.sharedInstance.loginState, userPage.id == page.id {
            controller.viewModel = MyPageCollectionViewModel()
        } else {
            controller.viewModel = PageProfileCollectionViewModel(profile: page)
        }
        navigationController.show(controller, sender: nil)
    }
}
