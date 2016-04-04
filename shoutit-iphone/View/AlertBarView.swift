//
//  AlertBarView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class AlertBarView: UIView {
    
    enum Type {
        case Success
        case Error
    }
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    
    func setAppearanceForAlertType(type: Type) {
        switch type {
        case .Success:
            backgroundColor = UIColor(shoutitColor: .SuccessGreen)
        case .Error:
            backgroundColor = UIColor(shoutitColor: .FailureRed)
        }
    }
}
