//
//  MediaPickerController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import MobileCoreServices

protocol MediaPickerControllerDelegate: class {
    func attachmentSelected(attachment: MediaAttachment, mediaPicker: MediaPickerController)
}

final class MediaPickerController: NSObject, MediaPicker  {

    var pickerSettings : MediaPickerSettings
    var selectedAttachments : [MediaAttachment]
    
    let videoProcessor = VideoProcessor()
    
    var presentingSubject : BehaviorSubject<UIViewController?>
    
    weak var delegate : MediaPickerControllerDelegate?
    
    init(delegate: MediaPickerControllerDelegate? = nil, settings: MediaPickerSettings = MediaPickerSettings()) {
        self.pickerSettings = settings
        self.presentingSubject = BehaviorSubject(value: nil)
        self.selectedAttachments = []
        super.init()
        
        self.delegate = delegate
    }
    
    func showMediaPickerController() {
        let controller = mediaPickerController(self.pickerSettings, sender: nil)
        controller.delegate = self
        self.presentingSubject.onNext(controller)
    }
    
    func mediaPickerController(settings: MediaPickerSettings = MediaPickerSettings(), sender: AnyObject? = nil) -> PhotosMenuController {
        let photosMenuController = CaptureViewController()
        photosMenuController.allowsVideos = settings.allowsVideos
        
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
    
    func photosMenuController(controller: PhotosMenuController, didPickImagePicker imagePicker: UIImagePickerController) {
        imagePicker.navigationBar.translucent = false
        imagePicker.navigationBar.barStyle = .Default
        imagePicker.navigationBar.barTintColor = UIColor(shoutitColor: .PrimaryGreen)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let attachment = MediaAttachment(type: .Image,
                                             uid: MediaAttachment.generateUid(),
                                             remoteURL: nil,
                                             thumbRemoteURL: nil,
                                             image: image,
                                             videoDuration: nil,
                                             originalData: image.dataRepresentation())
            self.attachmentSelected(attachment)
        }
        
        if let type = info[UIImagePickerControllerMediaType] as? String where type == (kUTTypeMovie as String) {
            if videoCanBeProcessed(info[UIImagePickerControllerMediaURL] as? NSURL) == false {
                picker.dismissViewControllerAnimated(true, completion: {
                    self.showToLongVideoAlert()
                })
            }
            processVideoFromURL(info[UIImagePickerControllerMediaURL] as? NSURL)
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func videoCanBeProcessed(url: NSURL?) -> Bool {
        guard let url = url else {
            return true
        }
        
        let duration = videoProcessor.videoDuration(url)
        
        return duration < 60.0
    }
    
    func showToLongVideoAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Video is too long", comment:""), message: NSLocalizedString("The maximum length of the video is 60 seconds. Choose a shorter movie.", comment: ""), preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        
        self.presentingSubject.onNext(alertController)
        return
    }
    
    func processVideoFromURL(url: NSURL?) {
        
        guard let url = url else { return }
        
        videoProcessor.generateMovieData(url) {[weak self] (data) -> Void in
            guard let `self` = self, data = data else { return }
            let image = self.videoProcessor.generateThumbImage(url)
            let attachment = MediaAttachment(type: .Video,
                                             uid: MediaAttachment.generateUid(),
                                             remoteURL: nil,
                                             thumbRemoteURL: nil,
                                             image: image,
                                             videoDuration: self.videoProcessor.videoDuration(url),
                                             originalData: data)
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
