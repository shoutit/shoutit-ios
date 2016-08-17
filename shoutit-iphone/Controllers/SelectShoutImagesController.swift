//
//  SelectShoutImagesController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class SelectShoutImagesController: UICollectionViewController {
    
    private let shoutImageCellIdentifier = "shoutImageCellIdentifier"
    private let numberOfItems = 5
    
    private var selectedIdx : Int?
    
    var attachments : [Int : MediaAttachment]!
    
    var mediaPicker : MediaPickerController!
    var mediaUploader : MediaUploader!
    
    private var editingAttachment : MediaAttachment?
    private var editingCompletion : ((attachment: MediaAttachment) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mediaPicker = MediaPickerController(delegate: self)
        mediaUploader = MediaUploader(bucket: .ShoutImage)
        
        attachments = [:]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayout()
    }
    
    private func prepareLayout() {
        guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return}
        layout.itemSize = CGSize(width: 74, height: 74)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .Horizontal
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        if #available(iOS 9.0, *) {
            collectionView?.semanticContentAttribute = .ForceLeftToRight
        }
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft {
            collectionView?.transform = CGAffineTransformMakeScale(-1, 1)
        }
    }
}

extension SelectShoutImagesController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(shoutImageCellIdentifier, forIndexPath: indexPath) as! ShoutMediaCollectionViewCell
        cell.transform = collectionView.transform
        
        let attachment = attachments[indexPath.item]
        let task = self.mediaUploader.taskForAttachment(attachment)
        cell.fillWith(attachment)
        cell.fillWith(task)
        cell.setActive(indexActive(indexPath))
        
        return cell
    }
}

extension SelectShoutImagesController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if !indexActive(indexPath) {
            return
        }
        
        if attachments[indexPath.item] != nil {
            selectedIdx = indexPath.item
            showEditAlert()
            return
        }
        
        selectedIdx = nil
        mediaPicker.showMediaPickerController()
    }
}

extension SelectShoutImagesController: MediaPickerControllerDelegate {
    
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
            if let oldAttachment = self.attachments[idx] {
                self.mediaUploader.removeTaskForAttachment(oldAttachment)
            }
            
            self.attachments[idx] = attachment
            self.collectionView?.reloadData()
            showPhotoEditingForAttechmentIfNeeded(attachment, completion: { [weak self] (editedAttachment) in
                if editedAttachment.originalData == nil { return }
                let task = self?.startUploadingAttachment(editedAttachment)
                self?.attachments[idx] = task?.attachment
                self?.collectionView?.reloadData()
            })
            return
        }
        
        toManyImagesAlert()
    }
}

private extension SelectShoutImagesController {
    
    func showPhotoEditingForAttechmentIfNeeded(attachment: MediaAttachment, completion: (attachment : MediaAttachment) -> Void ) {
        completion(attachment: attachment)
    }
}

private extension SelectShoutImagesController {
    
    func selectedAttachments() -> [MediaAttachment] {
        return Array(self.attachments.values)
    }
    
    func indexActive(indexPath: NSIndexPath) -> Bool {
        return indexPath.item <= selectedAttachments().count
    }
    
    func startUploadingAttachment(attachment: MediaAttachment) -> MediaUploadingTask {
        return mediaUploader.uploadAttachment(attachment)
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
        
        let title = NSLocalizedString("Cannot add more images", comment: "Alert title - user tries to pick more than allowed number of images in media picker")
        let message = NSLocalizedString("You can select only 5 images", comment: "Alert message - user tries to pick more than allowed number of images in media picker")
        let buttonTitle = LocalizedString.ok
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func toManyMoviesAlert() {
        
        let title = NSLocalizedString("Cannot add more videos", comment: "Alert title - user tries to pick more than allowed number of videos in media picker")
        let message = NSLocalizedString("You can select only 1 video", comment: "Alert message - user tries to pick more than allowed number of videos in media picker")
        let buttonTitle = LocalizedString.ok
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showEditAlert() {
        guard let idx = self.selectedIdx, _ = self.attachments[idx] else {
            return
        }
        
        let title = NSLocalizedString("Edit Shout Media", comment: "Edit media alert title")
        let cancelButtonTitle = LocalizedString.cancel

        let deleteButtonTitle = LocalizedString.delete
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: {[weak self] (alertAction) in
            self?.selectedIdx = nil
        }))
        
        alert.addAction(UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {[weak self] (alertAction) in
            if let selectedIdx = self?.selectedIdx {
                if let attachment = self?.attachments[selectedIdx] {
                    self?.mediaUploader.removeTaskForAttachment(attachment)
                    self?.attachments[selectedIdx] = nil
                    self?.rearangeAttachments()
                }
            }
            
            self?.collectionView?.reloadData()
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
        for idx in 0..<numberOfItems {
            if attachments[idx] == nil {
                return idx
            }
        }
        
        return nil
    }
}

