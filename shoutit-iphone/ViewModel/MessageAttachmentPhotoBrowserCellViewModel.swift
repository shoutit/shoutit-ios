//
//  MessageAttachmentPhotoBrowserCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import MWPhotoBrowser
import SDWebImage

class MessageAttachmentPhotoBrowserCellViewModel: NSObject, MWPhotoProtocol {
    
    var attachment: MessageAttachment? {
        didSet {
            if case .Some(.VideoAttachment(let video)) = attachment?.type() {
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
    private var webImageOperation: SDWebImageOperation?
    private var videoURLLoadedBlock: (NSURL -> Void)?
    private let isThumbnail: Bool
    private var loadingInProgress = false
    private unowned let parent: MessageAttachmentPhotoBrowserViewModel
    
    init(attachment: MessageAttachment?, isThumbnail: Bool, parent: MessageAttachmentPhotoBrowserViewModel) {
        self.parent = parent
        self.attachment = attachment
        self.isThumbnail = isThumbnail
        if case .VideoAttachment(_)? = attachment?.type() {
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
        if case .ImageAttachment(let p)? = attachment.type() {
            path = p
        } else if case .VideoAttachment(let video)? = attachment.type() {
            path = video.thumbnailPath
        } else {
            loadingInProgress = false
            return
        }
        
        SDWebImageManager.sharedManager()
            .downloadImageWithURL(path.toURL(), options: [], progress: {[weak self] (receivedSize, expectedSize) in
                guard let `self` = self else { return }
                if (expectedSize > 0) {
                    let progress = Float(receivedSize) / Float(expectedSize)
                    let dict = NSDictionary(objects: [NSNumber(float: progress), self], forKeys: ["progress", "photo"])
                    NSNotificationCenter.defaultCenter().postNotificationName(MWPHOTO_PROGRESS_NOTIFICATION, object: dict)
                }
            }) {[weak self] (image, error, cacheType, finished, imageURL) in
                self?.webImageOperation = nil
                self?.underlyingImage = image
                dispatch_async(dispatch_get_main_queue(), { 
                    self?.imageLoadingComplete()
                })
        }
    }
    
    func unloadUnderlyingImage() {
        loadingInProgress = false
        underlyingImage = nil
    }
    
    func getVideoURL(completion: ((NSURL!) -> Void)!) {
        guard let attachment = attachment else {
            videoURLLoadedBlock = completion
            return
        }
        if case .Some(.VideoAttachment(let video)) = attachment.type() {
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
        dispatch_async(dispatch_get_main_queue()) { 
            NSNotificationCenter.defaultCenter().postNotificationName(MWPHOTO_LOADING_DID_END_NOTIFICATION, object: self)
        }
    }
}
