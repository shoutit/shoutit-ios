//
//  MediaUploader.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import AmazonS3RequestManager

enum MediaUploaderBucket {
    case UserImage
    case ShoutImage
    case TagImage
    
    func bucketBasePath() -> String {
        switch (self) {
        case .UserImage: return "https://user-image.static.shoutit.com/"
        case .ShoutImage: return "https://shout-image.static.shoutit.com/"
        case .TagImage: return "https://tag-image.static.shoutit.com/"
        }
    }
    
    func bucketName() -> String {
        switch (self) {
        case .UserImage: return "shoutit-user-image-original"
        case .ShoutImage: return "shoutit-shout-image-original"
        case .TagImage: return "shoutit-tag-image-original"
        }
    }
}

final class MediaUploader: AnyObject {
    
    private let amazonAccessKey = "AKIAJW62O3PBJT3W3HJA"
    private let amazonSecretKey = "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"
    
    var tasks : [MediaUploadingTask]!
    
    let bucket : MediaUploaderBucket!
    
    var amazonManager : AmazonS3RequestManager!
    
    init(bucket: MediaUploaderBucket) {
        self.bucket = bucket
        
        tasks = []
        
        createAmazonS3Manager()
    }
    
    func createAmazonS3Manager() {
        amazonManager = AmazonS3RequestManager(bucket: self.bucket.bucketName(), region: .EUWest1, accessKey: amazonAccessKey, secret: amazonSecretKey)
    }
    
    func uploadAttachment(attachment: MediaAttachment) -> MediaUploadingTask {
        
        if let task = taskForAttachment(attachment) {
            return task
        }
        
        let task = MediaUploadingTask(attachment: attachment)
     
        self.tasks.append(task)
        
        startTask(task)
        
        return task
    }
    
    func startTask(task: MediaUploadingTask) {
        guard let user = Account.sharedInstance.user else {
            fatalError("Uploading without user account not supported.")
        }
        
        if task.attachment.type == .Image {
            uploadImageAttachment(task, user: user)
            return
        }
        
        uploadVideoAttachment(task, user: user)
        
    }
    
    func removeAttachment(attachment: MediaAttachment) {
        if let task = self.taskForAttachment(attachment) {
            if let idx = self.tasks.indexOf(task) {
                self.tasks.removeAtIndex(idx)
            }
        }
    }
    
    func uploadImageAttachment(task: MediaUploadingTask, user: User) {
        if let data = task.attachment.originalData {
            let destination = task.attachment.remoteFilename(user)
            let request = amazonManager.putObject(data, destinationPath: destination)
            task.request = request
            task.attachment.remoteURL = NSURL(string: self.bucket.bucketBasePath() + destination)
        }
    }
    
    func uploadVideoAttachment(task: MediaUploadingTask, user: User) {
        if let data = task.attachment.originalData {
            let destination = task.attachment.remoteFilename(user)
            let request = amazonManager.putObject(data, destinationPath: destination)
            task.request = request
            task.attachment.remoteURL = NSURL(string: self.bucket.bucketBasePath() + destination)
        }
        
        if let data = task.attachment.image?.dataRepresentation() {
            let destination = task.attachment.thumbRemoteFilename(user)
            
            amazonManager.putObject(data, destinationPath: destination)
            
            task.attachment.thumbRemoteURL = NSURL(string: self.bucket.bucketBasePath() + destination)
        }
    }
    
    func taskForAttachment(attachment: MediaAttachment?) -> MediaUploadingTask? {
        guard let _ = attachment else {
            return nil
        }
        
        for task in self.tasks {
            if task.attachment == attachment {
                return task
            }
        }
        
        return nil
    }
    
}
