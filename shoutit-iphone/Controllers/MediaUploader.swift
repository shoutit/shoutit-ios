//
//  MediaUploader.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import AmazonS3RequestManager
import ShoutitKit

enum MediaUploaderBucket {
    case userImage
    case shoutImage
    case tagImage
    
    func bucketBasePath() -> String {
        switch (self) {
        case .userImage: return "https://user-image.static.shoutit.com/"
        case .shoutImage: return "https://shout-image.static.shoutit.com/"
        case .tagImage: return "https://tag-image.static.shoutit.com/"
        }
    }
    
    func bucketName() -> String {
        switch (self) {
        case .userImage: return "shoutit-user-image-original"
        case .shoutImage: return "shoutit-shout-image-original"
        case .tagImage: return "shoutit-tag-image-original"
        }
    }
}

final class MediaUploader: AnyObject {
    
    fileprivate let amazonAccessKey = "AKIAJW62O3PBJT3W3HJA"
    fileprivate let amazonSecretKey = "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"
    
    var tasks : [MediaUploadingTask]!
    let bucket : MediaUploaderBucket!
    var amazonManager : AmazonS3RequestManager!
    
    init(bucket: MediaUploaderBucket) {
        self.bucket = bucket
        self.tasks = []
        createAmazonS3Manager()
    }
    
    func uploadAttachment(_ attachment: MediaAttachment) -> MediaUploadingTask {
        if let task = taskForAttachment(attachment) { return task }
        guard let originalData = attachment.originalData else { fatalError() }
        guard let user = Account.sharedInstance.user else { fatalError("Uploading without user account not supported.") }
        let task = MediaUploadingTask(attachment: attachment)
        let destination = task.attachment.remoteFilename(user)
        let request = amazonManager.putObject(originalData, destinationPath: destination)
        task.request = request
        task.attachment.remoteURL = URL(string: bucket.bucketBasePath() + destination)
        if let data = task.attachment.image?.dataRepresentation(), attachment.type == .Video {
            let destination = task.attachment.thumbRemoteFilename(user)
            amazonManager.putObject(data, destinationPath: destination)
            task.attachment.thumbRemoteURL = URL(string: bucket.bucketBasePath() + destination)
        }
        tasks.append(task)
        return task
    }
    
    func taskForAttachment(_ attachment: MediaAttachment?) -> MediaUploadingTask? {
        guard let _ = attachment else { return nil }
        for task in tasks {
            if task.attachment == attachment {
                return task
            }
        }
        return nil
    }
    
    func removeTaskForAttachment(_ attachment: MediaAttachment) {
        if let task = taskForAttachment(attachment) {
            if let idx = tasks.index(of: task) {
                self.tasks.remove(at: idx)
            }
        }
    }
    
    fileprivate func createAmazonS3Manager() {
        amazonManager = AmazonS3RequestManager(bucket: bucket.bucketName(), region: .euWest1, accessKey: amazonAccessKey, secret: amazonSecretKey)
    }
}
