//
//  AlertBarView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class AlertBarView: UIView {
    
    enum Type {
        case success
        case error
    }
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    
    func setAppearanceForAlertType(_ type: Type) {
        switch type {
        case .success:
            backgroundColor = UIColor(shoutitColor: .successGreen)
        case .error:
            backgroundColor = UIColor(shoutitColor: .failureRed)
        }
    }
}
