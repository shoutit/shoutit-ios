//
//  ConversationLoadMoreFooter.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 21.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum LoadMoreState {
    case ReadyToLoad
    case Loading
    case NoMore
}

class ConversationLoadMoreFooter: UITableViewHeaderFooterView {

    @IBOutlet weak var loadMoreButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    func setState(state: LoadMoreState) {
        
        loadMoreButton.hidden = (state == .Loading)
        activityIndicatorView.hidden = (state == .ReadyToLoad || state == .NoMore)

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
