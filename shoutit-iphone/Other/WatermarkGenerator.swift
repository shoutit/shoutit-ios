//
//  WatermarkGenerator.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation

enum WatermarkPosition {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
    case Default
}

final class WatermarkGenerator: AnyObject {
    
    func watermark(video videoAsset:AVAsset, watermarkText text : String, saveToLibrary flag : Bool, watermarkPosition position : WatermarkPosition, completion : ((status : AVAssetExportSessionStatus!, session: AVAssetExportSession!, outputURL : NSURL!) -> ())?) {
        self.watermark(video: videoAsset, watermarkText: text, imageName: nil, saveToLibrary: flag, watermarkPosition: position) { (status, session, outputURL) -> () in
            completion!(status: status, session: session, outputURL: outputURL)
        }
    }
    
    func watermark(video videoAsset:AVAsset, imageName name : String, saveToLibrary flag : Bool, watermarkPosition position : WatermarkPosition, completion : ((status : AVAssetExportSessionStatus!, session: AVAssetExportSession!, outputURL : NSURL!) -> ())?) {
        self.watermark(video: videoAsset, watermarkText: nil, imageName: name, saveToLibrary: flag, watermarkPosition: position) { (status, session, outputURL) -> () in
            completion!(status: status, session: session, outputURL: outputURL)
        }
    }
    
    private func watermark(video videoAsset:AVAsset, watermarkText text : String!, imageName name : String!, saveToLibrary flag : Bool, watermarkPosition position : WatermarkPosition, completion : ((status : AVAssetExportSessionStatus!, session: AVAssetExportSession!, outputURL : NSURL!) -> ())?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
            let mixComposition = AVMutableComposition()
            
            
            // 2 - Create video tracks
            let compositionVideoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            let clipVideoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
            
            try? compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: clipVideoTrack, atTime: kCMTimeZero)
            
            clipVideoTrack.preferredTransform
            
            // Video size
            let videoSize = clipVideoTrack.naturalSize
            
            
            let parentLayer = CALayer()
            parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
            parentLayer.opaque = true
            parentLayer.backgroundColor = UIColor.clearColor().CGColor
            
            let videoLayer = CALayer()
            videoLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
            
            videoLayer.opaque = true
            videoLayer.backgroundColor = UIColor.clearColor().CGColor
            
            parentLayer.addSublayer(videoLayer)
            
            if text != nil {
                let titleLayer = self.textLayerWithText(text, videoSize: videoSize)
                parentLayer.addSublayer(titleLayer)
            }
            
            if name != nil {
                let imageLayer = self.imageLayerWithImageNamed(name, videoSize: videoSize, position: position)
                parentLayer.addSublayer(imageLayer)
            }
            
            let videoComp = AVMutableVideoComposition()
            videoComp.renderSize = videoSize
            videoComp.frameDuration = CMTime(value: 1, timescale: 30) // 30 FPS
            videoComp.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
            
            /// instruction
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.backgroundColor = UIColor.clearColor().CGColor
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration)
            
            let layerInstruction = self.videoCompositionInstructionForTrack(compositionVideoTrack, asset: videoAsset)
            
            
            instruction.layerInstructions = [layerInstruction]
            videoComp.instructions = [instruction]
            
            // 4 - Get path
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
            let savePath = documentDirectory.stringByAppendingPathComponent("shoutitvideo-\(NSDate().timeIntervalSince1970).mov")
            let url = NSURL(fileURLWithPath: savePath)
            
            // 5 - Create Exporter
            guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
                return
            }
            
            exporter.outputURL = url
            exporter.outputFileType = AVFileTypeQuickTimeMovie
            exporter.shouldOptimizeForNetworkUse = true
            exporter.videoComposition = videoComp
            
            // 6 - Perform the Export
            exporter.exportAsynchronouslyWithCompletionHandler() {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if exporter.status == AVAssetExportSessionStatus.Completed {
                        let outputURL = exporter.outputURL
                        if flag {
                            // Save to library
                            let library = ALAssetsLibrary()
                            if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL) {
                                library.writeVideoAtPathToSavedPhotosAlbum(outputURL,
                                    completionBlock: { (assetURL:NSURL!, error:NSError!) -> Void in
                                        completion!(status: AVAssetExportSessionStatus.Completed, session: exporter, outputURL: outputURL)
                                })
                            }
                        } else {
                            // Dont svae to library
                            completion!(status: AVAssetExportSessionStatus.Completed, session: exporter, outputURL: outputURL)
                        }
                        
                    } else {
                        // Error
                        completion!(status: exporter.status, session: exporter, outputURL: nil)
                    }
                })
            }
        })
    }
    
    private func imageLayerWithImageNamed(imageName: String, videoSize: CGSize, position: WatermarkPosition) -> CALayer {
        guard let watermarkImage = UIImage(named: imageName) else {
            return CALayer()
        }
        
        let imageLayer = CALayer()
        imageLayer.contents = watermarkImage.CGImage
        
        imageLayer.frame = self.imageWatermarkPosition(watermarkImage, videoSize: videoSize, position: position)
        imageLayer.opacity = 0.2
        imageLayer.masksToBounds = true
        imageLayer.opaque = true
        imageLayer.backgroundColor = UIColor.clearColor().CGColor
        
        return imageLayer
    }
    
    private func textLayerWithText(text: String, videoSize: CGSize) -> CATextLayer {
        let titleLayer = CATextLayer()
        titleLayer.backgroundColor = UIColor.clearColor().CGColor
        titleLayer.foregroundColor = UIColor.whiteColor().CGColor
        titleLayer.shadowOpacity = 0.5
        titleLayer.string = text
        titleLayer.fontSize = 15
        titleLayer.opaque = true
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height)
        
        return titleLayer
    }
    
    private func imageWatermarkPosition(image: UIImage, videoSize: CGSize, position: WatermarkPosition) -> CGRect {
        
        let imageLayer = CALayer()
        imageLayer.contents = image.CGImage
        
        var xPosition : CGFloat = 0.0
        var yPosition : CGFloat = 0.0
        let padding : CGFloat = 10.0
        
        switch (position) {
        case .TopLeft:
            xPosition = padding
            yPosition = padding
            break
        case .TopRight:
            xPosition = videoSize.width - image.size.width - padding
            yPosition = padding
            break
        case .BottomLeft:
            xPosition = padding
            yPosition = videoSize.height - 60.0 - padding
            break
        case .BottomRight, .Default:
            xPosition = videoSize.width - image.size.width - padding
            yPosition = videoSize.height - 60.0 - padding
            break
        }

        return CGRect(x: xPosition, y: yPosition, width: image.size.width, height: image.size.height)
    }
    
    private func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.Up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .Right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .Left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .Up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .Down
        }
        return (assetOrientation, isPortrait)
    }
    
    private func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        
        let transform = assetTrack.preferredTransform
        
        instruction.setTransform(assetTrack.preferredTransform, atTime: kCMTimeZero)
        
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            instruction.setTransform(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor),
                                     atTime: kCMTimeZero)
        } else {
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            var concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.width / 2))
            if assetInfo.orientation == .Down {
                let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
                let windowBounds = UIScreen.mainScreen().bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
                concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
            }
            instruction.setTransform(concat, atTime: kCMTimeZero)
        }
 
        
        return instruction
    }}
