//
//  EditProfileDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol EditProfileDisplayable {
    func showEditProfile() -> Void
    func showEditPage() -> Void
}

extension FlowController : EditProfileDisplayable {
    
    func showEditProfile() -> Void {
        
        if case .Page(let user, let page) = Account.sharedInstance.loginState {
            
        }
        
        let controller = Wireframe.editProfileTableViewController()
        controller.viewModel = EditProfileTableViewModel()
        let nav = ModalNavigationController(rootViewController: controller)
        nav.navigationBar.barTintColor = UIColor(shoutitColor: .PrimaryGreen)
        nav.navigationBar.tintColor = UIColor.whiteColor()
        navigationController.presentViewController(nav, animated: true, completion: nil)
    }
    
    func showEditPage(page: DetailedPageProfile) -> Void {
        let controller = Wireframe.editPageTableViewController()
        controller.viewModel = EditPageTableViewModel(page)
        let nav = ModalNavigationController(rootViewController: controller)
        nav.navigationBar.barTintColor = UIColor(shoutitColor: .PrimaryGreen)
        nav.navigationBar.tintColor = UIColor.whiteColor()
        navigationController.presentViewController(nav, animated: true, completion: nil)
    }
}
