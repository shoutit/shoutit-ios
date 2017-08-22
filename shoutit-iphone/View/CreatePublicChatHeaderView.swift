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
        case url(path: String)
        case image(image: UIImage?)
    }
    
    enum ImageState {
        case noImage
        case uploading
        case uploaded
    }
    
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var chatSubjectTextField: FormTextField!
    
    // photo
    @IBOutlet weak var chatImageButton: UIButton!
    @IBOutlet weak var chatImageProgressView: ACPDownloadView!
    @IBOutlet weak var chatImageImageView: UIImageView!
    @IBOutlet weak var chatImageOverlayView: UIView!
    
    func setupImageViewWithStatus(_ status: ImageState) {
        
        switch status {
        case .noImage:
            chatImageButton.setImage(UIImage.cameraIconGray(), for: UIControlState())
            chatImageButton.isHidden = false
            chatImageOverlayView.isHidden = true
            chatImageProgressView.isHidden = true
        case .uploading:
            chatImageButton.isHidden = true
            chatImageOverlayView.isHidden = false
            chatImageProgressView.isHidden = false
            chatImageProgressView.setIndicatorStatus(.running)
        case .uploaded:
            chatImageButton.setImage(UIImage.cameraIconWhite(), for: UIControlState())
            chatImageButton.isHidden = false
            chatImageOverlayView.isHidden = false
            chatImageProgressView.isHidden = true
            chatImageProgressView.setIndicatorStatus(.none)
        }
    }
    
    func setChatImage(_ image: Image) {
        switch image {
        case .url(let path):
            chatImageImageView.sh_setImageWithURL(path.toURL(), placeholderImage: nil)
        case .image(let image):
            chatImageImageView.sh_cancelImageDownload()
            chatImageImageView.image = image
        }
    }
}
