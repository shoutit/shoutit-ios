//
//  SelectShoutImagesController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import Nemo

class SelectShoutImagesController: UICollectionViewController, MediaPicker {
    
    private let shoutImageCellIdentifier = "shoutImageCellIdentifier"
    
    var pickerSettings : MediaPickerSettings!
    var attachmentAtIndex : [Int : MediaAttachment?]!
    var selectedIdx : Int?

    var presentingSubject : BehaviorSubject<UIViewController?>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        presentingSubject = BehaviorSubject(value: nil)
        
        self.attachmentAtIndex = [:]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerSettings = MediaPickerSettings()
    }
    
    func selectedImages() -> [UIImage] {
        return []
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(shoutImageCellIdentifier, forIndexPath: indexPath) as! ShoutMediaCollectionViewCell
        
        if let attachment = self.attachmentAtIndex[indexPath.item] {
            cell.fillWith(attachment)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if self.attachmentAtIndex[indexPath.item] != nil {
            selectedIdx = indexPath.item
        } else {
            selectedIdx = nil
        }
        
        
        showMediaPickerController()
    }
    
    func showMediaPickerController() {
        let controller = mediaPickerController(self.pickerSettings, sender: nil)
        
        controller.delegate = self
        
        self.presentingSubject.onNext(controller)
    }
    
    

    func attachmentSelected(attachment: MediaAttachment) {
        
        if let selectedIdx = selectedIdx {
            self.attachmentAtIndex[selectedIdx] = attachment
            self.collectionView?.reloadData()
            return
        }
        
        for (idx, attach) in self.attachmentAtIndex {
            if attach == nil {
                self.attachmentAtIndex[idx] = attachment
            }
        }
        
        self.collectionView?.reloadData()
    }
}

extension SelectShoutImagesController {
    func mediaPickerController(settings: MediaPickerSettings = MediaPickerSettings(), sender: AnyObject? = nil) -> PhotosMenuController {
        let photosMenuController = Nemo.PhotosMenuController()
        
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
            let attachment = MediaAttachment(type: .Image, image: image, originalData: nil, remoteURL: nil, thumbRemoteURL: nil)
            self.attachmentSelected(attachment)
        }
        
    }
}
