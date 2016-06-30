//
//  VideoProcessor.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 08.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import AssetsLibrary
import MediaPlayer
import MobileCoreServices

final class VideoProcessor: AnyObject {

    func generateThumbImage(url: NSURL) -> UIImage? {
        let asset = AVAsset(URL: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        imageGenerator.appliesPreferredTrackTransform = true
        
        var duration = asset.duration
        
        duration.value = 0
        
        do {
            let imageRef = try imageGenerator.copyCGImageAtTime(duration, actualTime: nil)
            return UIImage(CGImage: imageRef)
        } catch {
            // Do Nothing
        }
        
        return nil
    }
    
    func videoDuration(url: NSURL) -> Float? {
        let asset = AVAsset(URL: url)
        
        return Float(CMTimeGetSeconds(asset.duration))
    }
    
    func generateMovieData(url: NSURL, handler: (data: NSData?) -> Void) {
        let asset = AVAsset(URL: url)
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) {
            
            let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] + "/tempVideo\(NSDate().timeIntervalSince1970).mp4"
            exporter.outputURL = NSURL(fileURLWithPath: documentPath)
            
            
            exporter.outputFileType = AVFileTypeMPEG4
            exporter.shouldOptimizeForNetworkUse = true
            
            
            exporter.exportAsynchronouslyWithCompletionHandler {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if exporter.status == .Completed {
                        if let outputURL = exporter.outputURL {
                            let data = NSData(contentsOfURL: outputURL)
                            handler(data: data)
                        }
                    } else {
                        print(exporter.error)
                    }
                })
            }
        }
    }
}
