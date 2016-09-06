//
//  ChangeLocationDisplayable.swift
//  shoutit
//
//  Created by Piotr Bernad on 06/09/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol ChangeLocationDisplayable {
    func showChangeLocation() -> Void
}

extension FlowController : ChangeLocationDisplayable {
    func showChangeLocation() {
        let controller = Wireframe.locationViewController()
        
        controller.finishedBlock = { [weak navigationController](_) in
            navigationController?.popViewControllerAnimated(true)
        }
        
        navigationController.showViewController(controller, sender: nil)
    }
}