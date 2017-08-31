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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol MediaPickerControllerDelegate: class {
    func attachmentSelected(_ attachment: MediaAttachment, mediaPicker: MediaPickerController)
}

final class MediaPickerController: NSObject, MediaPicker  {

    var pickerSettings : MediaPickerSettings
    var selectedAttachments : [MediaAttachment]
    
    let videoProcessor = VideoProcessor()
    
    var presentingSubject : PublishSubject<UIViewController?>
    
    weak var delegate : MediaPickerControllerDelegate?
    
    init(delegate: MediaPickerControllerDelegate? = nil, settings: MediaPickerSettings = MediaPickerSettings()) {
        self.pickerSettings = settings
        self.presentingSubject = PublishSubject()
        self.selectedAttachments = []
        super.init()
        
        self.delegate = delegate
    }
    
    func showMediaPickerController() {
        let controller = mediaPickerController(self.pickerSettings, sender: nil)
        controller.delegate = self
        self.presentingSubject.onNext(controller)
    }
    
    func mediaPickerController(_ settings: MediaPickerSettings = MediaPickerSettings(), sender: AnyObject? = nil) -> PhotosMenuController {
        let photosMenuController = CaptureViewController()
        photosMenuController.allowsVideos = settings.allowsVideos
        
        if let popoverPresentationController = photosMenuController.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender as? UIBarButtonItem
        }
        
        return photosMenuController
    }
    
    func photosMenuController(_ controller: PhotosMenuController, didPickPhotos photos: [PHAsset]) {
        
        for photo in photos {
            
            let options = PHImageRequestOptions()
            
            options.deliveryMode = .fastFormat
            
            PHImageManager.default().requestImage(for: photo,
                targetSize: self.pickerSettings.targetSize,
                contentMode: self.pickerSettings.contentMode,
                options: options,
                resultHandler: { (result, info) -> Void in
                    
                    let attachment = photo.asMediaAttachment(result)
                    self.attachmentSelected(attachment)
            })
        }
    }
    
    func photosMenuControllerDidCancel(_ controller: PhotosMenuController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func photosMenuController(_ controller: PhotosMenuController, didPickImagePicker imagePicker: UIImagePickerController) {
        imagePicker.navigationBar.isTranslucent = false
        imagePicker.navigationBar.barStyle = .default
        imagePicker.navigationBar.barTintColor = UIColor(shoutitColor: .primaryGreen)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let attachment = MediaAttachment(type: .image,
                                             uid: MediaAttachment.generateUid(),
                                             remoteURL: nil,
                                             thumbRemoteURL: nil,
                                             image: image,
                                             videoDuration: nil,
                                             originalData: image.dataRepresentation())
            self.attachmentSelected(attachment)
        }
        
        if let type = info[UIImagePickerControllerMediaType] as? String, type == (kUTTypeMovie as String) {
            if videoCanBeProcessed(info[UIImagePickerControllerMediaURL] as? URL) == false {
                picker.dismiss(animated: true, completion: {
                    self.showToLongVideoAlert()
                })
            }
            processVideoFromURL(info[UIImagePickerControllerMediaURL] as? URL)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func videoCanBeProcessed(_ url: URL?) -> Bool {
        guard let url = url else {
            return true
        }
        
        let duration = videoProcessor.videoDuration(url)
        
        return duration < 60.0
    }
    
    func showToLongVideoAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Video is too long", comment:""), message: NSLocalizedString("The maximum length of the video is 60 seconds. Choose a shorter movie.", comment: "To long movie error message"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil))
        
        self.presentingSubject.onNext(alertController)
        return
    }
    
    func processVideoFromURL(_ url: URL?) {
        
        guard let url = url else { return }
        
        videoProcessor.generateMovieData(url) {[weak self] (data) -> Void in
            guard let `self` = self, let data = data else { return }
            let image = self.videoProcessor.generateThumbImage(url)
            let attachment = MediaAttachment(type: .video,
                                             uid: MediaAttachment.generateUid(),
                                             remoteURL: nil,
                                             thumbRemoteURL: nil,
                                             image: image,
                                             videoDuration: self.videoProcessor.videoDuration(url),
                                             originalData: data)
            self.attachmentSelected(attachment)
        }
    }
    
    func attachmentSelected(_ attachment: MediaAttachment) {
        
        self.selectedAttachments.append(attachment)
        if let delegate = delegate {
            delegate.attachmentSelected(attachment, mediaPicker: self)
        }
    }
}
