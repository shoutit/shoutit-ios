////
////  WatermarkGenerator.swift
////  shoutit-iphone
////
////  Created by Piotr Bernad on 25/04/16.
////  Copyright © 2016 Shoutit. All rights reserved.
////
//
//import UIKit
//import AssetsLibrary
//import AVFoundation
////import LLVideoEditor
//
//enum WatermarkPosition {
//    case TopLeft
//    case TopRight
//    case BottomLeft
//    case BottomRight
//    case Default
//}
//
//final class WatermarkGenerator: AnyObject {
//    
//    func watermark(videoAssetURL:NSURL, watermarkText text : String, saveToLibrary flag : Bool, watermarkPosition position : WatermarkPosition, completion : ((status : AVAssetExportSessionStatus!, session: AVAssetExportSession!, outputURL : NSURL!) -> ())?) {
//        self.watermark(video: videoAssetURL, watermarkText: text, imageName: nil, saveToLibrary: flag, watermarkPosition: position) { (status, session, outputURL) -> () in
//            completion!(status: status, session: session, outputURL: outputURL)
//        }
//    }
//    
//    func watermark(videoAssetURL:NSURL, imageName name : String, saveToLibrary flag : Bool, watermarkPosition position : WatermarkPosition, completion : ((status : AVAssetExportSessionStatus!, session: AVAssetExportSession!, outputURL : NSURL!) -> ())?) {
//        self.watermark(video: videoAssetURL, watermarkText: nil, imageName: name, saveToLibrary: flag, watermarkPosition: position) { (status, session, outputURL) -> () in
//            completion!(status: status, session: session, outputURL: outputURL)
//        }
//    }
//    
//    private func watermark(video videoAssetURL:NSURL, watermarkText text : String!, imageName name : String!, saveToLibrary flag : Bool, watermarkPosition position : WatermarkPosition, completion : ((status : AVAssetExportSessionStatus!, session: AVAssetExportSession!, outputURL : NSURL!) -> ())?) {
//        
//        let videoEditor = LLVideoEditor(videoURL: videoAssetURL)
//    
//        let clipVideoTrack = AVAsset(URL: videoAssetURL).tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack
//        let videoSize = clipVideoTrack.naturalSize
//         
//        if name != nil {
//            let imageLayer = self.imageLayerWithImageNamed(name, videoSize: videoSize, position: position)
//            videoEditor.addLayer(imageLayer)
//        }
//         
//        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
//        let savePath = documentDirectory.stringByAppendingPathComponent("shoutitvideo-\(NSDate().timeIntervalSince1970).mov")
//        let exportURL = NSURL(fileURLWithPath: savePath)
//        
//        videoEditor.exportToUrl(exportURL, completionBlock: { (session) in
//            completion!(status: session.status, session: session, outputURL: exportURL)
//        })
//    }
//    
//    private func imageLayerWithImageNamed(imageName: String, videoSize: CGSize, position: WatermarkPosition) -> CALayer {
//        guard let watermarkImage = UIImage(named: imageName) else {
//            return CALayer()
//        }
//        
//        let imageLayer = CALayer()
//        imageLayer.contents = watermarkImage.CGImage
//        
//        imageLayer.frame = self.imageWatermarkPosition(watermarkImage, videoSize: videoSize, position: position)
//        imageLayer.opacity = 0.2
//        imageLayer.masksToBounds = true
//        imageLayer.opaque = true
//        imageLayer.backgroundColor = UIColor.clearColor().CGColor
//        
//        return imageLayer
//    }
//    
//    private func textLayerWithText(text: String, videoSize: CGSize) -> CATextLayer {
//        let titleLayer = CATextLayer()
//        titleLayer.backgroundColor = UIColor.clearColor().CGColor
//        titleLayer.foregroundColor = UIColor.whiteColor().CGColor
//        titleLayer.shadowOpacity = 0.5
//        titleLayer.string = text
//        titleLayer.fontSize = 15
//        titleLayer.opaque = true
//        titleLayer.alignmentMode = kCAAlignmentCenter
//        titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height)
//        
//        return titleLayer
//    }
//    
//    private func imageWatermarkPosition(image: UIImage, videoSize: CGSize, position: WatermarkPosition) -> CGRect {
//        
//        let imageLayer = CALayer()
//        imageLayer.contents = image.CGImage
//        
//        var xPosition : CGFloat = 0.0
//        var yPosition : CGFloat = 0.0
//        let padding : CGFloat = 10.0
//        
//        switch (position) {
//        case .TopLeft:
//            xPosition = padding
//            yPosition = padding
//            break
//        case .TopRight:
//            xPosition = videoSize.width - image.size.width - padding
//            yPosition = padding
//            break
//        case .BottomLeft:
//            xPosition = padding
//            yPosition = videoSize.height - 60.0 - padding
//            break
//        case .BottomRight, .Default:
//            xPosition = videoSize.width - image.size.width - padding
//            yPosition = videoSize.height - 60.0 - padding
//            break
//        }
//        
//        return CGRect(x: xPosition, y: yPosition, width: image.size.width, height: image.size.height)
//    }
//    
//    private func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
//        var assetOrientation = UIImageOrientation.Up
//        var isPortrait = false
//        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
//            assetOrientation = .Right
//            isPortrait = true
//        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
//            assetOrientation = .Left
//            isPortrait = true
//        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
//            assetOrientation = .Up
//        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
//            assetOrientation = .Down
//        }
//        return (assetOrientation, isPortrait)
//    }
//    
//    private func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
//        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
//        let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
//        
//        let transform = assetTrack.preferredTransform
//        
//        instruction.setTransform(assetTrack.preferredTransform, atTime: kCMTimeZero)
//        
//        let assetInfo = orientationFromTransform(transform)
//        
//        var scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.width
//        if assetInfo.isPortrait {
//            scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.height
//            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
//            instruction.setTransform(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor),
//                                     atTime: kCMTimeZero)
//        } else {
//            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
//            var concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.width / 2))
//            if assetInfo.orientation == .Down {
//                let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
//                let windowBounds = UIScreen.mainScreen().bounds
//                let yFix = assetTrack.naturalSize.height + windowBounds.height
//                let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
//                concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
//            }
//            instruction.setTransform(concat, atTime: kCMTimeZero)
//        }
//        
//        
//        return instruction
//    }}
