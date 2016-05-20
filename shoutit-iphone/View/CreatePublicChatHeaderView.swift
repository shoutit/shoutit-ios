//
//  CreatePublicChatHeaderView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 13.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ACPDownload

class CreatePublicChatHeaderView: UIView {
    
    enum Image {
        case URL(path: String)
        case Image(image: UIImage?)
    }
    
    enum ImageState {
        case NoImage
        case Uploading
        case Uploaded
    }
    
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var chatSubjectTextField: FormTextField!
    
    // photo
    @IBOutlet weak var chatImageButton: UIButton!
    @IBOutlet weak var chatImageProgressView: ACPDownloadView!
    @IBOutlet weak var chatImageImageView: UIImageView!
    @IBOutlet weak var chatImageOverlayView: UIView!
    
    func setupImageViewWithStatus(status: ImageState) {
        
        switch status {
        case .NoImage:
            chatImageButton.setImage(UIImage.cameraIconGray(), forState: .Normal)
            chatImageButton.hidden = false
            chatImageOverlayView.hidden = true
            chatImageProgressView.hidden = true
        case .Uploading:
            chatImageButton.hidden = true
            chatImageOverlayView.hidden = false
            chatImageProgressView.hidden = false
            chatImageProgressView.setIndicatorStatus(.Running)
        case .Uploaded:
            chatImageButton.setImage(UIImage.cameraIconWhite(), forState: .Normal)
            chatImageButton.hidden = false
            chatImageOverlayView.hidden = false
            chatImageProgressView.hidden = true
            chatImageProgressView.setIndicatorStatus(.None)
        }
    }
    
    func setChatImage(image: Image) {
        switch image {
        case .URL(let path):
            chatImageImageView.sh_setImageWithURL(path.toURL(), placeholderImage: nil)
        case .Image(let image):
            chatImageImageView.sh_cancelImageDownload()
            chatImageImageView.image = image
        }
    }
}
