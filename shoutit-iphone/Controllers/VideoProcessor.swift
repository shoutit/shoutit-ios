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
        
        let generator = WatermarkGenerator()
        
        generator.watermark(video: asset, imageName:"shoutit_logo_white", saveToLibrary: true, watermarkPosition: .TopRight) { (status, session, outputURL) in
            if status == .Completed {
                let data = NSData(contentsOfURL: outputURL)
                handler(data: data)
            }
        }
    }
}
