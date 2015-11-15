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
    
    private var player: MPMoviePlayerController?
    private var videoAsset: AVAsset?
    
    required init(viewController: SHVideoPreviewViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    func closeButtonAction() {
    }
    
    func nextButtonAction() {
    }
}
