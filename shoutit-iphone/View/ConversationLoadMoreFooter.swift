//
//  ConversationLoadMoreFooter.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 21.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum LoadMoreState {
    case notReady
    case readyToLoad
    case loading
    case noMore
}

final class ConversationLoadMoreFooter: UITableViewHeaderFooterView {

    @IBOutlet weak var loadMoreButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    func setState(_ state: LoadMoreState) {
        
        if (state == .loading || state == .notReady) {
            loadMoreButton.isHidden = true
        } else {
            loadMoreButton.isHidden = false
        }
        
        if (state == .readyToLoad || state == .noMore || state == .notReady) {
            activityIndicatorView.isHidden = true
        } else {
            activityIndicatorView.isHidden = false
        }

        if state == .noMore {
            loadMoreButton.setTitle(NSLocalizedString("No more messages to show", comment: "No More messages placeholder"), for: UIControlState())
            loadMoreButton.isEnabled = false
        } else {
            loadMoreButton.setTitle(NSLocalizedString("Tap to load archive messages", comment: "Load more messages button title"), for: UIControlState())
            loadMoreButton.isEnabled = true
        }
        
        if state == .loading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
        
    }
}
