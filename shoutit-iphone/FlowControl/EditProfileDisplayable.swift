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
    func showEditPageForDetailedProfile(_ page: DetailedPageProfile) -> Void
    func showEditPage(_ page: Profile) -> Void
}

extension FlowController : EditProfileDisplayable {
    
    func showEditProfile() -> Void {
        
        if case .some(.page(_, let page)) = Account.sharedInstance.loginState {
            self.showEditPageForDetailedProfile(page)
            return
        }
        
        let controller = Wireframe.editProfileTableViewController()
        controller.viewModel = EditProfileTableViewModel()
        let nav = ModalNavigationController(rootViewController: controller)
        nav.navigationBar.barTintColor = UIColor(shoutitColor: .primaryGreen)
        nav.navigationBar.tintColor = UIColor.white
        navigationController.present(nav, animated: true, completion: nil)
    }
    
    func showEditPage(_ page: Profile) -> Void {
        let controller = Wireframe.editPageTableViewController()
        controller.viewModel = EditPageTableViewModel(profile: page)
        let nav = ModalNavigationController(rootViewController: controller)
        nav.navigationBar.barTintColor = UIColor(shoutitColor: .primaryGreen)
        nav.navigationBar.tintColor = UIColor.white
        navigationController.present(nav, animated: true, completion: nil)
    }
    
    func showEditPageForDetailedProfile(_ page: DetailedPageProfile) -> Void {
        let controller = Wireframe.editPageTableViewController()
        controller.viewModel = EditPageTableViewModel(page: page)
        let nav = ModalNavigationController(rootViewController: controller)
        nav.navigationBar.barTintColor = UIColor(shoutitColor: .primaryGreen)
        nav.navigationBar.tintColor = UIColor.white
        navigationController.present(nav, animated: true, completion: nil)
    }
}
