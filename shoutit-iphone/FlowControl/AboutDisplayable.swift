//
//  AboutDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol AboutDisplayable {
    func showAboutInterface() -> Void
}

extension AboutDisplayable where Self: FlowController, Self: AboutTableViewControllerFlowDelegate {
    
    func showAboutInterface() {
        let aboutViewController = Wireframe.aboutTableViewController()
        aboutViewController.flowDelegate = self
        navigationController.showViewController(aboutViewController, sender: nil)
    }
}
