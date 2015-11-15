//
//  SHVideoPreviewViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import MobileCoreServices
import MediaPlayer

class SHVideoPreviewViewModel: NSObject, ViewControllerModelProtocol {

    private let viewController: SHVideoPreviewViewController
    
    private var player = MPMoviePlayerController()
    private var videoAsset: AVAsset?
    
    required init(viewController: SHVideoPreviewViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            // Do Nothing
        }
        
        self.player.view.frame = self.viewController.playerView.bounds
        self.player.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        self.viewController.playerView.addSubview(self.player.view)
        
        if let videoFileURL = self.viewController.videoFileURL {
            self.videoAsset = AVAsset(URL: videoFileURL)
            self.viewController.thumbImage = self.generateThumbImage(videoFileURL)
        }
        self.videoOutput()
    }
    
    func viewWillAppear() {
        self.player.play()
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        self.player.stop()
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    func closeButtonAction() {
        if let videoURL = self.viewController.videoFileURL {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(videoURL)
            } catch {
                // Do Nothing
            }
            self.viewController.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func nextButtonAction() {
        if let delegate = self.viewController.delegate, let fileURL = self.viewController.videoFileURL, let thumbImage = self.viewController.thumbImage {
            delegate.didVideoPreviewFinish(fileURL, thumbnailImage: thumbImage)
        }
        self.viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK - Private
    private func generateThumbImage(url: NSURL) -> UIImage? {
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
    
    private func videoOutput() {
        // 1 - Early exit if there's no video file selected
        if self.videoAsset == nil {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("LoadVideoAssetFirst", comment: "Please Load a Video Asset First"), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertActionStyle.Default, handler: nil))
            self.viewController.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // 2 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        
        // 3 - Video track
        let videoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        if let asset = videoAsset {
            do {
                SHProgressHUD.show(NSLocalizedString("PreparingVideo", comment: "Preparing video..."), maskType: .Black)
                if asset.tracksWithMediaType(AVMediaTypeAudio).count > 0 {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: asset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: kCMTimeZero)
                }
                
                if asset.tracksWithMediaType(AVMediaTypeVideo).count > 0 {
                    try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: asset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: kCMTimeZero)
                }
                
                // 3.1 - Create AVMutableVideoCompositionInstruction
                let mainInstruction = AVMutableVideoCompositionInstruction()
                mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
                
                // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
                let videolayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
                let videoAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
                var isVideoAssetPortrait = false
                let videoTransform = videoAssetTrack.preferredTransform
                if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
                    isVideoAssetPortrait = true
                }
                if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
                    isVideoAssetPortrait = true
                }
                videolayerInstruction.setTransform(videoAssetTrack.preferredTransform, atTime: kCMTimeZero)
                videolayerInstruction.setOpacity(0.0, atTime: asset.duration)
         
                // 3.3 - Add instructions
                mainInstruction.layerInstructions = [videolayerInstruction]
                
                let mainCompositionInst = AVMutableVideoComposition()
                let naturalSize: CGSize
                if isVideoAssetPortrait {
                    naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width)
                } else {
                    naturalSize = videoAssetTrack.naturalSize
                }
                mainCompositionInst.renderSize = CGSizeMake(naturalSize.width, naturalSize.height)
                mainCompositionInst.instructions = [mainInstruction]
                mainCompositionInst.frameDuration = CMTimeMake(1, 30)
                
                self.applyVideoEffects(mainCompositionInst, size: naturalSize)
                
                // 4 - Get path
                var outputFilePath: String? = ((NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("movie") as NSString).stringByAppendingPathExtension("mov")
                
                if var filePath = outputFilePath {
                    while NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                        filePath = ((NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(String(format: "movie-%ld", NSDate().timeIntervalSince1970)) as NSString).stringByAppendingPathExtension("mov")!
                    }
                    outputFilePath = filePath
                }
                
                if let filePath = outputFilePath {
                    let url = NSURL(fileURLWithPath: filePath)
                    // 5 - Create exporter
                    if let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality) {
                        exporter.outputURL = url
                        exporter.outputFileType = AVFileTypeQuickTimeMovie
                        exporter.shouldOptimizeForNetworkUse = true
                        exporter.videoComposition = mainCompositionInst

                        SHProgressHUD.show(NSLocalizedString("PreparingVideo", comment: "Preparing video..."), maskType: .Black)
                        exporter.exportAsynchronouslyWithCompletionHandler {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.exportDidFinish(exporter)
                            })
                        }
                    }
                }
                SHProgressHUD.dismiss()
            } catch {
                // Do Nothing
            }
        }
        
    }
    
    private func applyVideoEffects(composition: AVMutableVideoComposition, size: CGSize) {
        // 1 - set up the overlay
        let overlayLayer = CALayer()
        if let overlayImage = UIImage(named: "logoVideo") {
            overlayLayer.contents = overlayImage.CGImage
            let aspectRatio = overlayImage.size.height / overlayImage.size.width
            overlayLayer.frame = CGRectMake(size.width - size.width * 0.15 - size.height * 0.05, size.height - size.height * 0.15 , size.width * 0.15, size.width * 0.15 * aspectRatio)
            overlayLayer.masksToBounds = true
        }
        
        // 2 - set up the parent layer
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, size.width, size.height)
        videoLayer.frame = CGRectMake(0, 0, size.width, size.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
    }
    
    private func exportDidFinish(session: AVAssetExportSession) {
        SHProgressHUD.dismiss()
        if session.status == .Completed {
            self.viewController.videoFileURL = session.outputURL
            self.player.contentURL = self.viewController.videoFileURL
            self.player.prepareToPlay()
        }
    }
}
