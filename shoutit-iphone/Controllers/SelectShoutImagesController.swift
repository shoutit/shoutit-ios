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
    private var editingController : AdobeUXImageEditorViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mediaPicker = MediaPickerController(delegate: self)
        mediaUploader = MediaUploader(bucket: .ShoutImage)
        
        attachments = [:]
        
        AdobeImageEditorOpenGLManager.beginOpenGLLoad()
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
                self.mediaUploader.removeAttachment(oldAttachment)
            }
            
            self.attachments[idx] = attachment
            self.collectionView?.reloadData()
            showPhotoEditingForAttechmentIfNeeded(attachment, completion: { [weak self] (attachment) in
                self?.attachments[idx] = attachment
                self?.startUploadingAttachment(attachment)
                self?.collectionView?.reloadData()
            })
            return
        }
        
        toManyImagesAlert()
    }
}

extension SelectShoutImagesController : AdobeUXImageEditorViewControllerDelegate {
    
    
    func photoEditor(editor: AdobeUXImageEditorViewController, finishedWithImage image: UIImage?) {
        
        guard let image = image else {
            editor.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        editor.dismissViewControllerAnimated(true, completion: nil)
        
        guard let editingAttachment = editingAttachment, editingCompletion = editingCompletion else { return }
        guard let imageData = image.dataRepresentation() else {
            editingCompletion(attachment: editingAttachment)
            return
        }
        
        let newAttachment = editingAttachment.mediaAttachmentWithExchangedImage(image, data: imageData)
        editingCompletion(attachment: newAttachment)
        
        self.editingAttachment = nil
        self.editingCompletion = nil
    }
    
    func photoEditorCanceled(editor: AdobeUXImageEditorViewController) {
        if let editingAttachment = editingAttachment, editingCompletion = editingCompletion {
            editingCompletion(attachment: editingAttachment)
        }
        self.editingAttachment = nil
        self.editingCompletion = nil
        editingController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SelectShoutImagesController {
    
    func showPhotoEditingForAttechmentIfNeeded(attachment: MediaAttachment, completion: (attachment : MediaAttachment) -> Void ) {
        
        guard let img = attachment.image where attachment.type == .Image else {
            completion(attachment: attachment)
            return
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {[weak self] in
            guard self?.editingController?.presentingViewController == nil && self?.presentedViewController == nil else {
                completion(attachment: attachment)
                return
            }
            
            struct Static {
                static var token: dispatch_once_t = 0
            }
            dispatch_once(&Static.token) {
                AdobeUXImageEditorViewController.setAPIKey(Constants.Aviary.clientID, secret: Constants.Aviary.clientSecret)
            }
            
            self?.editingAttachment = attachment
            self?.editingCompletion = completion
            self?.editingController = AdobeUXImageEditorViewController(image: img)
            self?.editingController?.delegate = self
            self?.mediaPicker.presentingSubject.onNext(self?.editingController)
        }
    }
}

private extension SelectShoutImagesController {
    
    func selectedAttachments() -> [MediaAttachment] {
        return Array(self.attachments.values)
    }
    
    func indexActive(indexPath: NSIndexPath) -> Bool {
        return indexPath.item <= selectedAttachments().count
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
        
        let title = NSLocalizedString("Cannot add more images", comment: "Alert title - user tries to pick more than allowed number of images in media picker")
        let message = NSLocalizedString("You can select only 5 images", comment: "Alert message - user tries to pick more than allowed number of images in media picker")
        let buttonTitle = NSLocalizedString("OK", comment: "Alert button")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func toManyMoviesAlert() {
        
        let title = NSLocalizedString("Cannot add more videos", comment: "Alert title - user tries to pick more than allowed number of videos in media picker")
        let message = NSLocalizedString("You can select only 1 video", comment: "Alert message - user tries to pick more than allowed number of videos in media picker")
        let buttonTitle = NSLocalizedString("OK", comment: "Alert button")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showEditAlert() {
        guard let idx = self.selectedIdx, attachment = self.attachments[idx] else {
            return
        }
        
        let title = NSLocalizedString("Edit Shout Media", comment: "Edit media alert title")
        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "Edit photo action sheet option")
        let changeButtonTitle = NSLocalizedString("Edit", comment: "Edit photo action sheet option")
        let deleteButtonTitle = NSLocalizedString("Delete", comment: "Edit photo action sheet option")
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: {[weak self] (alertAction) in
            self?.selectedIdx = nil
        }))
        

        if attachment.type == .Image && attachment.image != nil {
            alert.addAction(UIAlertAction(title: changeButtonTitle, style: .Default, handler: {[weak self] (alertAction) in
            
            
                guard attachment.type == .Image else {
                    return
                }
            
                self?.showPhotoEditingForAttechmentIfNeeded(attachment, completion: { (atts) in
                    self?.mediaUploader.removeAttachment(attachment)
                    self?.attachments[idx] = atts
                    self?.startUploadingAttachment(atts)
                    self?.collectionView?.reloadData()
                })
                }))
        }
        
        alert.addAction(UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {[weak self] (alertAction) in
            if let selectedIdx = self?.selectedIdx {
                if let attachment = self?.attachments[selectedIdx] {
                    self?.mediaUploader.removeAttachment(attachment)
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

