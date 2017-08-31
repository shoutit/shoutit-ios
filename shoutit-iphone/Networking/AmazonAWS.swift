//
//  AmazonAWS.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import AWSS3
import AVFoundation
import ShoutitKit

final class AmazonAWS: NSObject {
    
    fileprivate(set) var images: [String] = []
    
    func reset() {
        images.removeAll()
        //videos.removeAll()
    }
    
    static func configureS3() {
        let credsProvider = AWSStaticCredentialsProvider(accessKey: Constants.AWS.SH_S3_ACCESS_KEY_ID, secretKey: Constants.AWS.SH_S3_SECRET_ACCESS_KEY)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.EUWest1, credentialsProvider: credsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func generateKeyWithExtenstion(_ ext: String) -> String {
        return String(format: "%@-%d.%@", UUID().uuidString, Int(Date().timeIntervalSince1970), ext)
    }
    
    func generateKey() -> String {
        return String(format: "%@-%d", UUID().uuidString, Int(Date().timeIntervalSince1970))
    }
    
    func getShoutImageTask(_ image: UIImage, progress: AWSNetworkingDownloadProgressBlock? = nil) -> AWSTask<AnyObject>? {
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(generateKeyWithExtenstion("jpg"))
        return getImageTask(image, filePath: filePath, bucket: Constants.AWS.SH_AMAZON_SHOUT_BUCKET, progress: progress)?.continueWith(block: { (task) -> AnyObject! in
            self.images.append(String(format: "%@%@", Constants.AWS.SH_AWS_SHOUT_URL, (filePath as NSString).lastPathComponent))
            return nil
        })
    }
    
    func getUserImageTask(_ image: UIImage, progress: AWSNetworkingDownloadProgressBlock? = nil) -> AWSTask<AnyObject>? {
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(generateKeyWithExtenstion("jpg"))
        return getImageTask(image, filePath: filePath, bucket: Constants.AWS.SH_AMAZON_USER_BUCKET, progress: progress)?.continueWith(block: { (task) -> AnyObject! in
            self.images.append(String(format: "%@%@", Constants.AWS.SH_AWS_USER_URL, (filePath as NSString).lastPathComponent))
            return nil
        })
        // return getImageTask(image, filePath: filePath, bucket: Constants.AWS.SH_AMAZON_USER_BUCKET)
    }
    
//    func getVideoUploadTasks(videoUrl: NSURL, image: UIImage) -> [AWSTask] {
//        var tasks: [AWSTask] = []
//        let key = generateKey()
//        let thumbnailFilePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(String(format: "%@_thumbnail.jpg", key))
//        //let video = SHMedia()
//        var isVideoDone = false
//        var isImageDone = false
//        let videoFileName = key.stringByAppendingString(".mp4")
//        if let task = getImageTask(image, filePath: thumbnailFilePath, bucket: Constants.AWS.SH_AMAZON_SHOUT_BUCKET) {
//            task.continueWithSuccessBlock({ (task) -> AnyObject! in
//                isImageDone = true
//                video.thumbnailUrl = String(format: "%@%@", Constants.AWS.SH_AWS_SHOUT_URL, (thumbnailFilePath as NSString).lastPathComponent)
//                if isVideoDone && isImageDone {
//                    self.videos.append(video)
//                }
//                return nil
//            })
//            tasks.append(task)
//        }
//        if let videoData = NSData(contentsOfURL: videoUrl) {
//            let asset = AVURLAsset(URL: videoUrl, options: nil)
//            video.duration = Int(CMTimeGetSeconds(asset.duration))
//            video.idOnProvider = videoFileName
//            video.provider = "shoutit_s3"
//            video.localThumbImage = image
//            video.localUrl = videoUrl
//            if let task = getObjectTask(videoUrl, bucket: Constants.AWS.SH_AMAZON_SHOUT_BUCKET, key: videoFileName, contentType: "video/mp4", contentLength: videoData.length) {
//                task.continueWithSuccessBlock({ (task) -> AnyObject! in
//                    video.url = String(format: "%@%@", Constants.AWS.SH_AWS_SHOUT_URL, videoFileName)
//                    isVideoDone = true
//                    if isVideoDone && isImageDone {
//                        self.videos.append(video)
//                    }
//                    return nil
//                })
//                tasks.append(task)
//            }
//        }
//        return tasks
//    }
    
    // MARK - Private
    fileprivate func getImageTask(_ image: UIImage, filePath: String, bucket: String, progress: AWSNetworkingDownloadProgressBlock? = nil) -> AWSTask<AnyObject>? {
        let image = image.resizeProportionally(intoNewSize: CGSize(width: 720, height: 720))
        if let data = UIImageJPEGRepresentation(image!, 1), ((try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])) != nil) {
            let fileUrl = URL(fileURLWithPath: filePath)
            let key = (filePath as NSString).lastPathComponent
            return getObjectTask(fileUrl, bucket: bucket, key: key, contentType: "image/jpg", contentLength: data.count, progress: progress)
        }
        return nil
    }
    
    fileprivate func getObjectTask(_ fileURL: URL, bucket: String, key: String, contentType: String, contentLength: Int, progress: AWSNetworkingDownloadProgressBlock? = nil) -> AWSTask<AnyObject>? {
        let request = AWSS3TransferManagerUploadRequest()
        request?.bucket = bucket
        request?.key = key
        request?.contentType = contentType
        request?.body = fileURL
        request?.contentLength = contentLength as NSNumber
        request?.uploadProgress = progress
        guard let rq = request else { return nil }
        return AWSS3TransferManager.default().upload(rq)
    }
}
