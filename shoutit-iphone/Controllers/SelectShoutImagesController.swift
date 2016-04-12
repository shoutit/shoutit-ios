//
//  SelectShoutImagesController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class SelectShoutImagesController: UICollectionViewController, MediaPickerControllerDelegate {
    
    private let shoutImageCellIdentifier = "shoutImageCellIdentifier"
    
    var selectedIdx : Int?
    
    var attachments : [Int : MediaAttachment]!
    
    var mediaPicker : MediaPickerController!
    var mediaUploader : MediaUploader!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mediaPicker = MediaPickerController(delegate: self)
        mediaUploader = MediaUploader(bucket: .ShoutImage)
        
        attachments = [:]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft) {
            self.collectionView?.transform = CGAffineTransformMakeScale(-1, 1)
        }
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(shoutImageCellIdentifier, forIndexPath: indexPath) as! ShoutMediaCollectionViewCell
        
        let modifiedIndexPath = indexPathForIndexPath(indexPath)
        
        let attachment = attachments[modifiedIndexPath.item]
        cell.fillWith(attachment)
        
        let task = self.mediaUploader.taskForAttachment(attachment)
        cell.fillWith(task)
        
        cell.setActive(indexActive(modifiedIndexPath))
        
        return cell
    }
    
    func indexPathForIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        if (UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft) {
            return NSIndexPath(forItem: 5 - indexPath.item, inSection: indexPath.section)
        } else {
            return indexPath
        }
    }
    
    func selectedAttachments() -> [MediaAttachment] {
        return Array(self.attachments.values) 
    }
    
    func indexActive(indexPath: NSIndexPath) -> Bool {
        let modifiedIndexPath = indexPathForIndexPath(indexPath)
        
        return modifiedIndexPath.item <= selectedAttachments().count
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let modifiedIndexPath = indexPathForIndexPath(indexPath)
        
        if !indexActive(modifiedIndexPath) {
            return
        }
        
        if attachments[modifiedIndexPath.item] != nil {
            selectedIdx = modifiedIndexPath.item
            showEditAlert()
            return
        }
        
        selectedIdx = nil
        
        mediaPicker.showMediaPickerController()
    }
    
    func attachmentSelected(attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        if checkIfAttachmentCanBeAdded(attachment) == false {
            return
        }
        
        var newAttachmentIdx : Int?
        
        if let selectedIdx = selectedIdx {
            newAttachmentIdx = selectedIdx
            self.selectedIdx = nil
        } else if let idx = firstEmptyIndex() {
            newAttachmentIdx = idx
        }
        
        
        if let idx = newAttachmentIdx {
            self.attachments[idx] = attachment
            
            startUploadingAttachment(attachment)
            
            self.collectionView?.reloadData()
            
            return
        }
        
        toManyImagesAlert()
    }
    
    func startUploadingAttachment(attachment: MediaAttachment) {
        mediaUploader.uploadAttachment(attachment)
    }
    
    func checkIfAttachmentCanBeAdded(attachment: MediaAttachment) -> Bool {
        if attachment.type == .Video {
            if checkIfVideoCanBeAdded() == false {
                toManyMoviesAlert()
                return false
            }
        }
        
        return true
    }
    
    func checkIfVideoCanBeAdded() -> Bool {
        var numberOfVideosAttached = 0
        
        for (_, attachment) in self.attachments {
            if attachment.type == .Video {
                numberOfVideosAttached += 1
            }
        }
        
        return numberOfVideosAttached < self.mediaPicker.pickerSettings.maximumVideos
    }
    
    func toManyImagesAlert() {
        let alert = UIAlertController(title: "Cannot add more images", message: "You can select only 5 images.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func toManyMoviesAlert() {
        let alert = UIAlertController(title: "Cannot add more videos", message: "You can select only 1 video.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showEditAlert() {
        let alert = UIAlertController(title: "Edit Shout Media", message: "", preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (alertAction) in
            self.selectedIdx = nil
        }))
        
        alert.addAction(UIAlertAction(title: "Change", style: .Default, handler: { (alertAction) in
            self.mediaPicker.showMediaPickerController()
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (alertAction) in
            if let selectedIdx = self.selectedIdx {
                if let attachment = self.attachments[selectedIdx] {
                    self.mediaUploader.removeAttachment(attachment)
                    self.attachments[selectedIdx] = nil
                    self.rearangeAttachments()
                }
            }
            
            self.collectionView?.reloadData()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func rearangeAttachments() {
        var atts : [Int : MediaAttachment] = [:]
        
        var idx = 0
        
        for att in selectedAttachments() {
            atts[idx] = att
            idx += 1
        }
        
        attachments = atts
        
    }
    
    func firstEmptyIndex() -> Int? {
        for idx in 0...5 {
            if attachments[idx] == nil {
                return idx
            }
        }
        
        return nil
    }
    
}

