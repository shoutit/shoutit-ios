//
//  EditProfileTableViewHeaderView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ACPDownload

class EditProfileTableViewHeaderView: UIView {
    
    enum ProgressType {
        case Cover
        case Avatar
    }
    
    // cover
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverButton: UIButton!
    @IBOutlet weak var coverUploadProgressView: ACPDownloadView!
    
    // avatar
    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.shadowColor = UIColor.grayColor().CGColor
            avatarContainerView.layer.shadowOpacity = 0.6
            avatarContainerView.layer.shadowRadius = 3.0
            avatarContainerView.layer.shadowOffset = CGSize(width: 2, height: 2)
            avatarContainerView.layer.masksToBounds = false
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
            avatarImageView.layer.borderWidth = 1
            avatarImageView.layer.cornerRadius = 5
            avatarImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var avatarButtonOverlay: UIView! {
        didSet {
            avatarButtonOverlay.layer.borderColor = UIColor.whiteColor().CGColor
            avatarButtonOverlay.layer.borderWidth = 1
            avatarButtonOverlay.layer.cornerRadius = 5
            avatarButtonOverlay.layer.masksToBounds = true
            avatarButtonOverlay.clipsToBounds = true
        }
    }
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var avatarUploadProgressView: ACPDownloadView!
    
    func hydrateProgressView(type: ProgressType, withStatus status: MediaUploadingTaskStatus) {
        
        let progressView = type == .Avatar ? avatarUploadProgressView : coverUploadProgressView
        let button = type == .Avatar ? avatarButton : coverButton
        
        switch (status) {
        case .Uploading:
            progressView.hidden = false
            button.hidden = true
            progressView.setIndicatorStatus(.Running)
        case .Error:
            button.hidden = false
            progressView.hidden = true
            progressView.setIndicatorStatus(.None)
        case .Uploaded:
            progressView.hidden = true
            button.hidden = false
        }
    }
}
