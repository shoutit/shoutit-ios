//
//  SHLoadMoreView.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 17/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHLoadMoreView: UIView {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!

    func showLoading () {
        self.loadingLabel.text = "Loading..."
        self.loadingIndicator.startAnimating()
    }
    
    func showNoMoreContent () {
        self.loadingLabel.text = ""
        self.loadingIndicator.stopAnimating()
    }

}
