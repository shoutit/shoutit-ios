//
//  SHPhotoPreviewViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHPhotoPreviewViewModel: NSObject, ViewControllerModelProtocol {

    private let viewController: SHPhotoPreviewViewController
    
    required init(viewController: SHPhotoPreviewViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if let photo = self.viewController.photo, let imageData = UIImageJPEGRepresentation(photo, 0.2), let image = UIImage(data: imageData) {
            self.viewController.photo = image.scaleAndRotateImage(image)
            self.viewController.photo = UIImage(CGImage: photo.CGImage!, scale: 0.5, orientation: photo.imageOrientation)
            self.viewController.photoImageView.image = photo
        }
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    func nextButtonAction() {
        if let delegate = self.viewController.delegate, let photo = self.viewController.photo {
            delegate.didPhotoPreviewFinish(photo)
            self.viewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func closeButtonAction() {
        self.viewController.navigationController?.popViewControllerAnimated(true)
    }
    
}
