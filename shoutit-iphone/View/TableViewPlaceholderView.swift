//
//  TableViewPlaceholderView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class TableViewPlaceholderView: UIView {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    func showMessage(message: String = NSLocalizedString("Content unavailable", comment: "")) {
        if activityIndicatorView.isAnimating() {
            activityIndicatorView.stopAnimating()
        }
        activityIndicatorView.hidden = true
        
        label.text = message
        label.hidden = false
    }
    
    func showActivity() {
        
        label.hidden = true
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
    }
}
