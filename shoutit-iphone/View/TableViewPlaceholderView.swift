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
    
    func showMessage(message: String? = NSLocalizedString("Content unavailable", comment: "Default table view placeholder"),
                     title: String? = nil,
                     image: UIImage? = nil)
    {
        adjustViewForDisplayingMessage()
        imageView.image = image
        label.text = message
        titleLabel.text = title
    }
    
    func showActivity() {
        titleLabel.hidden = true
        label.hidden = true
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
    }
    
    private func adjustViewForDisplayingMessage() {
        if activityIndicatorView.isAnimating() {
            activityIndicatorView.stopAnimating()
        }
        activityIndicatorView.hidden = true
        label.hidden = false
        titleLabel.hidden = false
    }
}
