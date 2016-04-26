//
//  ConversationLoadMoreFooter.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 21.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum LoadMoreState {
    case NotReady
    case ReadyToLoad
    case Loading
    case NoMore
}

final class ConversationLoadMoreFooter: UITableViewHeaderFooterView {

    @IBOutlet weak var loadMoreButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    func setState(state: LoadMoreState) {
        
        if (state == .Loading || state == .NotReady) {
            loadMoreButton.hidden = true
        } else {
            loadMoreButton.hidden = false
        }
        
        if (state == .ReadyToLoad || state == .NoMore || state == .NotReady) {
            activityIndicatorView.hidden = true
        } else {
            activityIndicatorView.hidden = false
        }

        if state == .NoMore {
            loadMoreButton.setTitle(NSLocalizedString("No more messages to show", comment: ""), forState: .Normal)
            loadMoreButton.enabled = false
        } else {
            loadMoreButton.setTitle(NSLocalizedString("Tap to load archive messages", comment: ""), forState: .Normal)
            loadMoreButton.enabled = true
        }
        
        if state == .Loading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
        
    }
}
