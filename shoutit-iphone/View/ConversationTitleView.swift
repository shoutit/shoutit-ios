//
//  ConversationTitleView.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationTitleView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        activityIndicator?.transform = CGAffineTransformMakeScale(0.7, 0.7)
    }
    
    func setTitle(title: String?, message: String?) {
        titleLabel.text = title
        
        if message?.characters.count > 0 {
            messageLabel.hidden = false
            messageLabel.text = message
            activityIndicator?.hidden = false
            activityIndicator?.startAnimating()
            moveTitleToTop()
        } else {
            messageLabel.hidden = true
            messageLabel.text = ""
            activityIndicator?.hidden = true
            activityIndicator?.stopAnimating()
            moveTitleToMiddle()
        }
    }
    
    func moveTitleToTop() {
        UIView.animateWithDuration(0.2, delay: 0, options:.BeginFromCurrentState, animations: {
            self.titleLabelTopConstraint.constant = 0
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func moveTitleToMiddle() {
        UIView.animateWithDuration(0.2, delay: 0, options:.BeginFromCurrentState, animations: {
            self.titleLabelTopConstraint.constant = 10.0
            self.layoutIfNeeded()
        }, completion: nil)
    }
}
