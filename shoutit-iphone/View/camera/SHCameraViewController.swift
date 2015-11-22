//
//  SHCameraViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

protocol SHCameraViewControllerDelegate {
    func didCameraFinish(image: UIImage)
    func didCameraFinish(tempVideoFileURL: NSURL, thumbnailImage: UIImage)
}

class SHCameraViewController: SHCameraControlViewController {

    var timeToRecord: Int = 0
    var isVideoCV: Bool = false
    var delegate: SHCameraViewControllerDelegate?
    var deviceAuthorized: Bool = false
    
    private var viewModel: SHCameraViewModel?
    
    @IBOutlet var gestureRecognizers: UITapGestureRecognizer!
    
    static func presentFromViewController(parent: UIViewController, onlyPhoto: Bool, timeToRecord: Int, isVideoCV: Bool, firstVideo: Bool, delegate: SHCameraViewControllerDelegate) {
        let cameraVC = SHCameraViewController(nibName: "CameraView", bundle: NSBundle.mainBundle())
        cameraVC.onlyPhoto = onlyPhoto
        cameraVC.isVideoCV = isVideoCV
        cameraVC.delegate = delegate
        cameraVC.timeToRecord = timeToRecord
        cameraVC.isVideo = firstVideo
        
        let navController = UINavigationController(rootViewController: cameraVC)
        navController.navigationBar.barTintColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
        navController.navigationBar.tintColor = UIColor.whiteColor()
        navController.setNavigationBarHidden(true, animated: false)
        parent.presentViewController(navController, animated: true, completion: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHCameraViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.viewDidDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        viewModel?.destroy()
    }

    @IBAction func toggleMovieRecording(sender: AnyObject) {
        viewModel?.toggleMovieRecording()
    }
    
    @IBAction func changeCamera(sender: AnyObject) {
        viewModel?.changeCamera()
    }
    
    @IBAction func snapStillImage(sender: AnyObject) {
        viewModel?.snapStillImage()
    }
    
    @IBAction func switchFlashButton(sender: AnyObject) {
        viewModel?.switchFlash()
    }
    
    @IBAction func switchFlash(sender: AnyObject) {
        viewModel?.switchFlash()
    }
    
    @IBAction func toggleVideoButton(sender: AnyObject) {
        viewModel?.toggleVideoButton()
    }
    
    @IBAction func openLibrary(sender: AnyObject) {
        viewModel?.openLibrary()
    }
    
    @IBAction func closeCamera(sender: AnyObject) {
        viewModel?.closeCamera()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
