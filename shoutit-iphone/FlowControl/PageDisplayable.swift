//
//  PageDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol PageDisplayable {
    func showPage(page: Profile) -> Void
}

extension PageDisplayable where Self: FlowController {
    
    func showPage(page: Profile) {
        navigationController.notImplemented()
    }
}
