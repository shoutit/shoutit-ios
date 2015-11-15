//
//  SHCameraPreviewView.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import AVFoundation

class SHCameraPreviewView: UIView {

    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.classForCoder()
    }
    
    func session() -> AVCaptureSession? {
        if let layer = self.layer as? AVCaptureVideoPreviewLayer {
            return layer.session
        }
        return nil
    }
    
    func setSession(session: AVCaptureSession) {
        if let layer = self.layer as? AVCaptureVideoPreviewLayer {
            layer.session = session
        }
    }

}
