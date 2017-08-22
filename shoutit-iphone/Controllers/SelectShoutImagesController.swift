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
    
    fileprivate let shoutImageCellIdentifier = "shoutImageCellIdentifier"
    fileprivate let numberOfItems = 5
    
    fileprivate var selectedIdx : Int?
    
    var attachments : [Int : MediaAttachment]!
    
    var mediaPicker : MediaPickerController!
    var mediaUploader : MediaUploader!
    
    fileprivate var editingAttachment : MediaAttachment?
    fileprivate var editingCompletion : ((_ attachment: MediaAttachment) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mediaPicker = MediaPickerController(delegate: self)
        mediaUploader = MediaUploader(bucket: .shoutImage)
        
        attachments = [:]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayout()
    }
    
    fileprivate func prepareLayout() {
        guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return}
        layout.itemSize = CGSize(width: 74, height: 74)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        if #available(iOS 9.0, *) {
            collectionView?.semanticContentAttribute = .forceLeftToRight
        }
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            collectionView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
}

extension SelectShoutImagesController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shoutImageCellIdentifier, for: indexPath) as! ShoutMediaCollectionViewCell
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
    
    func attachmentSelected(_ attachment: MediaAttachment, mediaPicker: MediaPickerController) {
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
    
    func showPhotoEditingForAttechmentIfNeeded(_ attachment: MediaAttachment, completion: (_ attachment : MediaAttachment) -> Void ) {
        completion(attachment)
    }
}

private extension SelectShoutImagesController {
    
    func selectedAttachments() -> [MediaAttachment] {
        return Array(self.attachments.values)
    }
    
    func indexActive(_ indexPath: IndexPath) -> Bool {
        return indexPath.item <= selectedAttachments().count
    }
    
    func startUploadingAttachment(_ attachment: MediaAttachment) -> MediaUploadingTask {
        return mediaUploader.uploadAttachment(attachment)
    }
    
    func checkIfAttachmentCanBeAdded(_ attachment: MediaAttachment) -> Bool {
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
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func toManyMoviesAlert() {
        
        let title = NSLocalizedString("Cannot add more videos", comment: "Alert title - user tries to pick more than allowed number of videos in media picker")
        let message = NSLocalizedString("You can select only 1 video", comment: "Alert message - user tries to pick more than allowed number of videos in media picker")
        let buttonTitle = LocalizedString.ok
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showEditAlert() {
        guard let idx = self.selectedIdx, let _ = self.attachments[idx] else {
            return
        }
        
        let title = NSLocalizedString("Edit Shout Media", comment: "Edit media alert title")
        let cancelButtonTitle = LocalizedString.cancel

        let deleteButtonTitle = LocalizedString.delete
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: {[weak self] (alertAction) in
            self?.selectedIdx = nil
        }))
        
        alert.addAction(UIAlertAction(title: deleteButtonTitle, style: .default, handler: {[weak self] (alertAction) in
            if let selectedIdx = self?.selectedIdx {
                if let attachment = self?.attachments[selectedIdx] {
                    self?.mediaUploader.removeTaskForAttachment(attachment)
                    self?.attachments[selectedIdx] = nil
                    self?.rearangeAttachments()
                }
            }
            
            self?.collectionView?.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
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

