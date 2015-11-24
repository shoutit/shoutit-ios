//
//  SHAmazonAWS.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 23/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import AWSS3

class SHAmazonAWS: NSObject {
    
    static func configureS3() {
        let credsProvider = AWSStaticCredentialsProvider(accessKey: Constants.AWS.SH_S3_ACCESS_KEY_ID, secretKey: Constants.AWS.SH_S3_SECRET_ACCESS_KEY)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.EUWest1, credentialsProvider: credsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    }
    
    static func generateKeyWithExtenstion(ext: String) -> String {
        return String(format: "%@-%d.%@", NSUUID().UUIDString, NSDate().timeIntervalSince1970, ext)
    }
    
    static func generateKey() -> String {
        return String(format: "%@-%d", NSUUID().UUIDString, NSDate().timeIntervalSince1970)
    }
    
    static func getShoutImageTask(image: UIImage) -> AWSTask? {
        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(SHAmazonAWS.generateKeyWithExtenstion("jpg"))
        return getImageTask(image, filePath: filePath, bucket: Constants.AWS.SH_AMAZON_SHOUT_BUCKET)
    }
    
    static func getUserImageTask(image: UIImage) -> AWSTask? {
        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(SHAmazonAWS.generateKeyWithExtenstion("jpg"))
        return getImageTask(image, filePath: filePath, bucket: Constants.AWS.SH_AMAZON_USER_BUCKET)
    }
    
    static func getVideoUploadTasks(videoUrl: NSURL, image: UIImage) -> [AWSTask] {
        var tasks: [AWSTask] = []
        let key = SHAmazonAWS.generateKey()
        let thumbnailFilePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(String(format: "%@_thumbnail.jpg", key))
        
        let videoFileName = key.stringByAppendingString(".mp4")
        if let task = getImageTask(image, filePath: thumbnailFilePath, bucket: Constants.AWS.SH_AMAZON_SHOUT_BUCKET) {
            tasks.append(task)
        }
        if let videoData = NSData(contentsOfFile: videoUrl.absoluteString), let task = getObjectTask(videoUrl, bucket: Constants.AWS.SH_AMAZON_SHOUT_BUCKET, key: videoFileName, contentType: "video/mp4", contentLength: videoData.length) {
            tasks.append(task)
        }
        return tasks
    }
    
    private static func getImageTask(image: UIImage, filePath: String, bucket: String) -> AWSTask? {
        let image = image.resizeImageProportionallyIntoNewSize(CGSizeMake(720, 720))
        if let data = UIImageJPEGRepresentation(image, 1) where data.writeToFile(filePath, atomically: true) {
            let fileUrl = NSURL(fileURLWithPath: filePath)
            data.length
            return getObjectTask(fileUrl, bucket: bucket, key: (filePath as NSString).lastPathComponent, contentType: "image/jpg", contentLength: data.length)
        }
        return nil
    }
    
    private static func getObjectTask(fileURL: NSURL, bucket: String, key: String, contentType: String, contentLength: Int) -> AWSTask? {
        let request = AWSS3TransferManagerUploadRequest()
        request.bucket = bucket
        request.key = key
        request.contentType = contentType
        request.body = fileURL
        request.contentLength = contentLength
        return AWSS3TransferManager.defaultS3TransferManager().upload(request)
    }
}
