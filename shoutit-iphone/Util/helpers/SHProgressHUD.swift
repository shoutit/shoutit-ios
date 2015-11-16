//
//  SHProgressHUD.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 10/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import SVProgressHUD

class SHProgressHUD: NSObject {

    static func show(status: String? = nil, maskType: SVProgressHUDMaskType = .Black) {
        if let message = status {
            SVProgressHUD.showWithStatus(message, maskType: maskType)
        } else {
            SVProgressHUD.showWithMaskType(maskType)
        }
    }
    
    static func showError(status: String? = nil, maskType: SVProgressHUDMaskType = .Black) {
        if let message = status {
            SVProgressHUD.showErrorWithStatus(message, maskType: maskType)
        }
    }
    
    static func dismiss() {
        SVProgressHUD.dismiss()
    }
    
}
