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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var labelToViewCenterYConstraint: NSLayoutConstraint!
    
    func showMessage(message: String? = NSLocalizedString("Content unavailable", comment: "Default table view placeholder"), image: UIImage? = nil) {
        if activityIndicatorView.isAnimating() {
            activityIndicatorView.stopAnimating()
        }
        activityIndicatorView.hidden = true
        
        imageView.image = image
        label.text = message
        label.hidden = false
    }
    
    func showActivity() {
        
        label.hidden = true
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
    }
}
