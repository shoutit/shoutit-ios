//
//  EditProfileTableViewHeaderView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ACPDownload

final class EditProfileTableViewHeaderView: UIView {
    
    enum ProgressType {
        case cover
        case avatar
    }
    
    // cover
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverButton: UIButton!
    @IBOutlet weak var coverUploadProgressView: ACPDownloadView!
    
    // avatar
    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.shadowColor = UIColor.gray.cgColor
            avatarContainerView.layer.shadowOpacity = 0.6
            avatarContainerView.layer.shadowRadius = 3.0
            avatarContainerView.layer.shadowOffset = CGSize(width: 2, height: 2)
            avatarContainerView.layer.masksToBounds = false
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.borderColor = UIColor.white.cgColor
            avatarImageView.layer.borderWidth = 1
            avatarImageView.layer.cornerRadius = 5
            avatarImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var avatarButtonOverlay: UIView! {
        didSet {
            avatarButtonOverlay.layer.borderColor = UIColor.white.cgColor
            avatarButtonOverlay.layer.borderWidth = 1
            avatarButtonOverlay.layer.cornerRadius = 5
            avatarButtonOverlay.layer.masksToBounds = true
            avatarButtonOverlay.clipsToBounds = true
        }
    }
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var avatarUploadProgressView: ACPDownloadView!
    
    func hydrateProgressView(_ type: ProgressType, withStatus status: MediaUploadingTaskStatus) {
        
        let progressView = type == .avatar ? avatarUploadProgressView : coverUploadProgressView
        let button = type == .avatar ? avatarButton : coverButton
        
        switch (status) {
        case .uploading:
            progressView?.isHidden = false
            button?.isHidden = true
            progressView?.setIndicatorStatus(.running)
        case .error:
            button?.isHidden = false
            progressView?.isHidden = true
            progressView?.setIndicatorStatus(.none)
        case .uploaded:
            progressView?.isHidden = true
            button?.isHidden = false
        }
    }
}
