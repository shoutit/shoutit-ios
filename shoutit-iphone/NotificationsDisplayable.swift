//
//  NotificationsDisplayable.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation


protocol NotificationsDisplayable {
    func showNotifications() -> Void
}

extension NotificationsDisplayable where Self: FlowController, Self: NotificationsTableViewControllerFlowDelegate {
    
    func showNotifications() {
        let controller = Wireframe.notificationsController()
        
        controller.flowDelegate = self
        
        self.navigationController.showViewController(controller, sender: nil)
    }
}
