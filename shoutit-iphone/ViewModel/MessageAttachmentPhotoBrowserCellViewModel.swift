//
//  MessageAttachmentPhotoBrowserCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit
import SDWebImage

class MessageAttachmentPhotoBrowserCellViewModel: NSObject, MWPhotoProtocol {
    
    var attachment: MessageAttachment? {
        didSet {
            if case .some(.videoAttachment(let video)) = attachment?.type() {
                isVideo = true
                if isThumbnail {
                    loadUnderlyingImageAndNotify()
                } else {
                    videoURLLoadedBlock?(video.path.toURL()!)
                    videoURLLoadedBlock = nil
                }
            } else {
                loadUnderlyingImageAndNotify()
            }
        }
    }
    var underlyingImage: UIImage?
    var isVideo: Bool
    fileprivate var webImageOperation: SDWebImageOperation?
    fileprivate var videoURLLoadedBlock: ((URL) -> Void)?
    fileprivate let isThumbnail: Bool
    fileprivate var loadingInProgress = false
    fileprivate unowned let parent: MessageAttachmentPhotoBrowserViewModel
    
    init(attachment: MessageAttachment?, isThumbnail: Bool, parent: MessageAttachmentPhotoBrowserViewModel) {
        self.parent = parent
        self.attachment = attachment
        self.isThumbnail = isThumbnail
        if case .videoAttachment(_)? = attachment?.type() {
            self.isVideo = true
        } else {
            self.isVideo = false
        }
        super.init()
    }
    
    func caption() -> String! {
        return nil
    }
    
    // MARK: - MWPhotoProtocol
    
    func loadUnderlyingImageAndNotify() {
        guard loadingInProgress == false else { return }
        loadingInProgress = true
        if let _ = underlyingImage {
            imageLoadingComplete()
        } else {
            performLoadUnderlyingImageAndNotify()
        }
    }
    
    func performLoadUnderlyingImageAndNotify() {
        guard let attachment = attachment else {
            loadingInProgress = false
            parent.fetchNextPage()
            return
        }
        
        let path: String
        if case .imageAttachment(let p)? = attachment.type() {
            path = p
        } else if case .videoAttachment(let video)? = attachment.type() {
            path = video.thumbnailPath
        } else {
            loadingInProgress = false
            return
        }
        
        SDWebImageManager.shared()
            .downloadImage(with: path.toURL() as! URL, options: [], progress: {[weak self] (receivedSize, expectedSize) in
                guard let `self` = self else { return }
                if (expectedSize > 0) {
                    let progress = Float(receivedSize) / Float(expectedSize)
                    let dict = NSDictionary(objects: [NSNumber(value: progress as Float), self], forKeys: ["progress" as NSCopying, "photo" as NSCopying])
                    NotificationCenter.defaultCenter().postNotificationName(MWPHOTO_PROGRESS_NOTIFICATION, object: dict)
                }
            }) {[weak self] (image, error, cacheType, finished, imageURL) in
                self?.webImageOperation = nil
                self?.underlyingImage = image
                DispatchQueue.main.async(execute: { 
                    self?.imageLoadingComplete()
                })
        }
    }
    
    func unloadUnderlyingImage() {
        loadingInProgress = false
        underlyingImage = nil
    }
    
    func getVideoURL(_ completion: ((URL?) -> Void)!) {
        guard let attachment = attachment else {
            videoURLLoadedBlock = completion
            return
        }
        if case .some(.videoAttachment(let video)) = attachment.type() {
            completion(video.path.toURL())
        }
    }
    
    func cancelAnyLoading() {
        webImageOperation?.cancel()
    }
}

private extension MessageAttachmentPhotoBrowserCellViewModel {
    
    func imageLoadingComplete() {
        loadingInProgress = false
        postCompleteNotification()
    }
    
    func postCompleteNotification() {
        DispatchQueue.main.async { 
            NotificationCenter.defaultCenter.postNotificationName(NSNotification.Name(rawValue: MWPHOTO_LOADING_DID_END_NOTIFICATION), object: self)
        }
    }
}
