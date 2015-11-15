//
//  SHCameraControlViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Photos

class SHCameraControlViewController: BaseViewController, UIScrollViewAccessibilityDelegate {

    @IBOutlet weak var previewView: SHCameraPreviewView!
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet var controlView: UIView!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    @IBOutlet weak var flashSwitchButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stillButton: UIButton!
    @IBOutlet weak var switchModeButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var flashView: UIView!
    
    @IBOutlet weak var constraintBottomPreviewView: NSLayoutConstraint!
    @IBOutlet weak var constraintTopPreviewView: NSLayoutConstraint!
    
    @IBOutlet weak var openLibraryView: UIView!
    @IBOutlet weak var openLibraryImageView: UIImageView!
    @IBOutlet weak var openLibraryButton: UIButton!
    
    var currentInterfaceOrientation: UIInterfaceOrientation = .Portrait
    var onlyPhoto: Bool = false
    var isVideo: Bool = false
    var lastImage: UIImage?
    var lastVideo: UIImage?
    
    private var angle: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var orient = UIApplication.sharedApplication().statusBarOrientation
        if (orient != .Portrait || orient != .PortraitUpsideDown || orient != .LandscapeLeft || orient != .LandscapeRight) {
            orient = .Portrait
        }
        self.currentInterfaceOrientation = orient
        self.switchModeButton.hidden = onlyPhoto
        self.setMode(isVideo)
        self.visualEffectView.alpha = 1
        self.visualEffectView.hidden = false
        
        self.openLibraryImageView.contentMode = .ScaleAspectFill
        self.openLibraryImageView.clipsToBounds = true
        self.openLibraryImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.openLibraryImageView.layer.borderWidth = 1.5
        self.openLibraryImageView.layer.cornerRadius = 8.0
        self.rotateViewTo(self.currentInterfaceOrientation)
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        var fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Video, options: fetchOptions)
        if let lastVideoAsset = fetchResult.lastObject as? PHAsset {
            PHImageManager.defaultManager().requestImageForAsset(lastVideoAsset, targetSize: CGSizeMake(400, 400), contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler: { (result, info) -> Void in
                if (result != nil) {
                    self.lastVideo = result
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if self.isVideo {
                            self.openLibraryImageView.image = self.lastVideo
                        }
                    })
                }
            })
        }
        
        fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        if let lastImageAsset = fetchResult.lastObject as? PHAsset {
            PHImageManager.defaultManager().requestImageForAsset(lastImageAsset, targetSize: CGSizeMake(400, 400), contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler: { (result, info: [NSObject : AnyObject]?) -> Void in
                if (result != nil) {
                    self.lastImage = result
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if !self.isVideo {
                            self.openLibraryImageView.image = self.lastImage
                        }
                    })
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setFlashButtonMode(mode: AVCaptureFlashMode) {
        switch mode {
        case .Auto:
            self.flashSwitchButton.setTitle(NSLocalizedString("Auto", comment: "Auto"), forState: .Normal)
        case .On:
            self.flashSwitchButton.setTitle(NSLocalizedString("On", comment: "On"), forState: .Normal)
        case .Off:
            self.flashSwitchButton.setTitle(NSLocalizedString("Off", comment: "Off"), forState: .Normal)
        }
    }
    
    func startRecording(record: Bool) {
        if record {
            self.recordButton.setBackgroundImage(UIImage(named: "cameraVideoStop"), forState: .Normal)
        } else {
            self.recordButton.setBackgroundImage(UIImage(named: "cameraVideo"), forState: .Normal)
        }
    }
    
    func toggleVideoButton() {
        self.isVideo = !self.isVideo
        self.setMode(isVideo)
    }
    
    // MARK - Private
    private func setMode(isVideo: Bool) {
        self.isVideo = isVideo
        UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveEaseIn, animations: { () -> Void in
            self.recordButton.alpha = !isVideo ? 0 : 1
            self.stillButton.alpha = isVideo ? 0 : 1
            self.toolbar.alpha = isVideo ? 0 : 0.7
            self.timerLabel.alpha = !isVideo ? 0 : 1
            }) { (finished) -> Void in
                self.timerLabel.hidden = !isVideo
                self.recordButton.hidden = !isVideo
                self.stillButton.hidden = isVideo
                self.toolbar.hidden = isVideo
                self.openLibraryImageView.image = self.isVideo ? self.lastVideo : self.lastImage
                self.switchModeButton.setBackgroundImage(UIImage(named: !isVideo ? "cameraModeVideo" : "cameraModePhoto"), forState: .Normal)
        }
    }
    
    private func rotateViewTo(orientation: UIInterfaceOrientation) {
        self.currentInterfaceOrientation = orientation
        
        let angle = self.getAngleForOrientation(orientation)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseIn, animations: { () -> Void in
                let transform = CGAffineTransformMakeRotation(CGFloat(angle))
                self.flashView.transform = transform
                self.stillButton.transform = transform
                self.timerLabel.transform = transform
                self.switchModeButton.transform  = transform
                self.cameraSwitchButton.transform = transform
                self.closeButton.transform = transform
                self.openLibraryView.transform  = transform
                }, completion: nil)
        }
    }
    
    private func getAngleForOrientation(orientation: UIInterfaceOrientation) -> Double {
        switch(orientation) {
        case .Portrait:
            self.angle = 0
        case .PortraitUpsideDown:
            self.angle = M_PI
        case .LandscapeLeft:
            self.angle = -M_PI/2
        case.LandscapeRight:
            self.angle = M_PI/2
        default:
            self.angle = 0
        }
        return self.angle
    }
}
