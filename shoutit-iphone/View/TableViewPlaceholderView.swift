//
//  TableViewPlaceholderView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class TableViewPlaceholderView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var labelToViewCenterYConstraint: NSLayoutConstraint!
    
    func showMessage(_ message: String? = NSLocalizedString("Content unavailable", comment: "Default table view placeholder"),
                     title: String? = nil,
                     image: UIImage? = nil)
    {
        adjustViewForDisplayingMessage()
        imageView.image = image
        label.text = message
        titleLabel.text = title
    }
    
    func showActivity() {
        titleLabel.isHidden = true
        label.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    fileprivate func adjustViewForDisplayingMessage() {
        if activityIndicatorView.isAnimating {
            activityIndicatorView.stopAnimating()
        }
        activityIndicatorView.isHidden = true
        label.isHidden = false
        titleLabel.isHidden = false
    }
}
