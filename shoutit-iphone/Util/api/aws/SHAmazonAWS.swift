//
//  SHAmazonAWS.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 23/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import AWSS3
import AVFoundation

class SHAmazonAWS: NSObject {
    
    private(set) var images: [String] = []
    private(set) var videos: [SHMedia] = []
    
    func reset() {
        images.removeAll()
        videos.removeAll()
    }
    
    static func configureS3() {
        let credsProvider = AWSStaticCredentialsProvider(accessKey: Constants.AWS.SH_S3_ACCESS_KEY_ID, secretKey: Constants.AWS.SH_S3_SECRET_ACCESS_KEY)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.EUWest1, credentialsProvider: credsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    }
    
    func generateKeyWithExtenstion(ext: String) -> String {
        return String(format: "%@-%d.%@", NSUUID().UUIDString, NSDate().timeIntervalSince1970, ext)
    }
    
    func generateKey() -> String {
        return String(format: "%@-%d", NSUUID().UUIDString, NSDate().timeIntervalSince1970)
    }
    
    func getShoutImageTask(image: UIImage) -> AWSTask? {
        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(generateKeyWithExtenstion("jpg"))
        return getImageTask(image, filePath: filePath, bucket: Constants.AWS.SH_AMAZON_SHOUT_BUCKET)?.continueWithSuccessBlock({ (task) -> AnyObject! in
                self.images.append(String(format: "%@%@", Constants.AWS.SH_AWS_SHOUT_URL, (filePath as NSString).lastPathComponent))
            return nil
        })
    }
    
    func getUserImageTask(image: UIImage) -> AWSTask? {
        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(generateKeyWithExtenstion("jpg"))
        return getImageTask(image, filePath: filePath, bucket: Constants.AWS.SH_AMAZON_USER_BUCKET)
    }
    
    func getVideoUploadTasks(videoUrl: NSURL, image: UIImage) -> [AWSTask] {
        var tasks: [AWSTask] = []
        let key = generateKey()
        let thumbnailFilePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(String(format: "%@_thumbnail.jpg", key))
        let video = SHMedia()
        var isVideoDone = false
        var isImageDone = false
        let videoFileName = key.stringByAppendingString(".mp4")
        if let task = getImageTask(image, filePath: thumbnailFilePath, bucket: Constants.AWS.SH_AMAZON_SHOUT_BUCKET) {
            task.continueWithSuccessBlock({ (task) -> AnyObject! in
                isImageDone = true
                video.thumbnailUrl = String(format: "%@%@", Constants.AWS.SH_AWS_SHOUT_URL, (thumbnailFilePath as NSString).lastPathComponent)
                if isVideoDone && isImageDone {
                    self.videos.append(video)
                }
                return nil
            })
            tasks.append(task)
        }
        if let videoData = NSData(contentsOfURL: videoUrl) {
            let asset = AVURLAsset(URL: videoUrl, options: nil)
            video.duration = Int(CMTimeGetSeconds(asset.duration))
            video.idOnProvider = videoFileName
            video.provider = "shoutit_s3"
            video.localThumbImage = image
            video.localUrl = videoUrl
            if let task = getObjectTask(videoUrl, bucket: Constants.AWS.SH_AMAZON_SHOUT_BUCKET, key: videoFileName, contentType: "video/mp4", contentLength: videoData.length) {
                task.continueWithSuccessBlock({ (task) -> AnyObject! in
                    video.url = String(format: "%@%@", Constants.AWS.SH_AWS_SHOUT_URL, videoFileName)
                    isVideoDone = true
                    if isVideoDone && isImageDone {
                        self.videos.append(video)
                    }
                    return nil
                })
                tasks.append(task)
            }
        }
        return tasks
    }
    
    // MARK - Private
    private func getImageTask(image: UIImage, filePath: String, bucket: String) -> AWSTask? {
        let image = image.resizeImageProportionallyIntoNewSize(CGSizeMake(720, 720))
        if let data = UIImageJPEGRepresentation(image, 1) where data.writeToFile(filePath, atomically: true) {
            let fileUrl = NSURL(fileURLWithPath: filePath)
            let key = (filePath as NSString).lastPathComponent
            return getObjectTask(fileUrl, bucket: bucket, key: key, contentType: "image/jpg", contentLength: data.length)
        }
        return nil
    }
    
    private func getObjectTask(fileURL: NSURL, bucket: String, key: String, contentType: String, contentLength: Int) -> AWSTask? {
        let request = AWSS3TransferManagerUploadRequest()
        request.bucket = bucket
        request.key = key
        request.contentType = contentType
        request.body = fileURL
        request.contentLength = contentLength
        return AWSS3TransferManager.defaultS3TransferManager().upload(request)
    }
}
