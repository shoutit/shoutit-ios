//
//  SettingsDisplayable.swift
//  shoutit
//
//  Created by Piotr Bernad on 06/09/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

protocol SettingsDisplayable {
    func showSettings() -> Void
}

extension FlowController : SettingsDisplayable {
    func showSettings() {
        let controller = Wireframe.settingsViewController()
        
        controller.flowDelegate = self
        
        self.navigationController.showViewController(controller, sender: nil)
    }
}