//
//  MediaPickerController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import Nemo
import MobileCoreServices

protocol MediaPickerControllerDelegate {
    func attachmentSelected(attachment: MediaAttachment, mediaPicker: MediaPickerController)
}

class MediaPickerController: NSObject, MediaPicker  {

    var pickerSettings : MediaPickerSettings!
    var selectedAttachments : [MediaAttachment]!
    
    let videoProcessor = VideoProcessor()
    
    var presentingSubject : BehaviorSubject<UIViewController?>!
    
    var delegate : MediaPickerControllerDelegate?
    
    init(delegate: MediaPickerControllerDelegate? = nil) {
        super.init()
    
        presentingSubject = BehaviorSubject(value: nil)
        
        self.selectedAttachments = []
        
        pickerSettings = MediaPickerSettings()
        
        self.delegate = delegate
    }
    
    func showMediaPickerController() {
        let controller = mediaPickerController(self.pickerSettings, sender: nil)
        
        controller.delegate = self
        
        self.presentingSubject.onNext(controller)
    }
    
    func mediaPickerController(settings: MediaPickerSettings = MediaPickerSettings(), sender: AnyObject? = nil) -> PhotosMenuController {
        let photosMenuController = CaptureViewController()
        
        if let popoverPresentationController = photosMenuController.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender as? UIBarButtonItem
        }
        
        return photosMenuController
    }
    
    func photosMenuController(controller: PhotosMenuController, didPickPhotos photos: [PHAsset]) {
        for photo in photos {
            
            let options = PHImageRequestOptions()
            
            options.deliveryMode = .Opportunistic
            options.synchronous = true
            
            PHImageManager.defaultManager().requestImageForAsset(photo,
                targetSize: self.pickerSettings.targetSize,
                contentMode: self.pickerSettings.contentMode,
                options: options,
                resultHandler: { (result, info) -> Void in
                    
                    let attachment = photo.asMediaAttachment(result)
                    self.attachmentSelected(attachment)
            })
        }
        
    }
    
    func photosMenuControllerDidCancel(controller: PhotosMenuController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let attachment = MediaAttachment(type: .Image, image: image, originalData: image.dataRepresentation(), remoteURL: nil, thumbRemoteURL: nil, uid: MediaAttachment.generateUid(), videoDuration: nil)
            self.attachmentSelected(attachment)
        }
        
        if let type = info[UIImagePickerControllerMediaType] as? String {
            if type == (kUTTypeMovie as String) {
                processVideoFromURL(info[UIImagePickerControllerMediaURL] as? NSURL)
            }
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func processVideoFromURL(url: NSURL?) {
        guard let url = url else {
            return
        }
        
        videoProcessor.generateMovieData(url) { (data) -> Void in
            guard let data = data else {
                return
            }
            
            let image = self.videoProcessor.generateThumbImage(url)
            let attachment = MediaAttachment(type: .Video, image: image, originalData: data, remoteURL: nil, thumbRemoteURL: nil, uid: MediaAttachment.generateUid(), videoDuration: self.videoProcessor.videoDuration(url))
            self.attachmentSelected(attachment)
        }
    }
    
    func attachmentSelected(attachment: MediaAttachment) {
        self.selectedAttachments.append(attachment)

        if let delegate = delegate {
            delegate.attachmentSelected(attachment, mediaPicker: self)
        }
    }
}
