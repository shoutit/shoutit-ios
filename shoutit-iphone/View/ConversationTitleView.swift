//
//  ConversationTitleView.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


final class ConversationTitleView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        activityIndicator?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func setTitle(_ title: String?, message: String?) {
        titleLabel.text = title
        
        if message?.characters.count > 0 {
            messageLabel.isHidden = false
            messageLabel.text = message
            activityIndicator?.isHidden = false
            activityIndicator?.startAnimating()
            moveTitleToTop()
        } else {
            messageLabel.isHidden = true
            messageLabel.text = ""
            activityIndicator?.isHidden = true
            activityIndicator?.stopAnimating()
            moveTitleToMiddle()
        }
    }
    
    func moveTitleToTop() {
        UIView.animate(withDuration: 0.2, delay: 0, options:.beginFromCurrentState, animations: {
            self.titleLabelTopConstraint.constant = 0
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func moveTitleToMiddle() {
        UIView.animate(withDuration: 0.2, delay: 0, options:.beginFromCurrentState, animations: {
            self.titleLabelTopConstraint.constant = 10.0
            self.layoutIfNeeded()
        }, completion: nil)
    }
}
