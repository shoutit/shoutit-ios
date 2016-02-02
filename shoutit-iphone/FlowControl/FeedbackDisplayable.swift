//
//  FeedbackDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol FeedbackDisplayable {
    func showFeedbackInterface() -> Void
}

extension FeedbackDisplayable where Self: FlowController {
    
    func showFeedbackInterface() {
        UserVoice.presentUserVoiceInterfaceForParentViewController(navigationController)
    }
}
