//
//  HelpDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol HelpDisplayable {
    func showHelpInterface() -> Void
}

extension HelpDisplayable where Self: FlowController {
    
    func showHelpInterface() {
        UserVoice.presentUserVoiceInterfaceForParentViewController(navigationController)
    }
}
