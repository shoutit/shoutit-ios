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

    func generateThumbImage(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        imageGenerator.appliesPreferredTrackTransform = true
        
        var duration = asset.duration
        
        duration.value = 0
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: duration, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            // Do Nothing
        }
        
        return nil
    }
    
    func videoDuration(_ url: URL) -> Float? {
        let asset = AVAsset(url: url)
        
        return Float(CMTimeGetSeconds(asset.duration))
    }
    
    func generateMovieData(_ url: URL, handler: @escaping (_ data: Data?) -> Void) {
        let asset = AVAsset(url: url)
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) {
            
            let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/tempVideo\(Date().timeIntervalSince1970).mp4"
            exporter.outputURL = URL(fileURLWithPath: documentPath)
            
            
            exporter.outputFileType = AVFileTypeMPEG4
            exporter.shouldOptimizeForNetworkUse = true
            
            
            exporter.exportAsynchronously {
                DispatchQueue.main.async(execute: { () -> Void in
                    if exporter.status == .completed {
                        if let outputURL = exporter.outputURL {
                            let data = try? Data(contentsOf: outputURL)
                            handler(data)
                        }
                    } else {
                        print(exporter.error)
                    }
                })
            }
        }
    }
}
