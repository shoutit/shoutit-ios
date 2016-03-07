//
//  EditProfileDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol EditProfileDisplayable {
    func showEditProfile() -> Void
}

extension EditProfileDisplayable where Self: FlowController {
    
    func showEditProfile() {
        
        let controller = Wireframe.editProfileTableViewController()
        controller.viewModel = EditProfileTableViewModel()
        
        navigationController.showViewController(controller, sender: nil)
    }
}
