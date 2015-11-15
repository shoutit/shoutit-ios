//
//  SHVideoPreviewViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

protocol SHVideoPreviewViewControllerDelegate {
    func didVideoPreviewFinish(tempVideoFileURL: NSURL, thumbnailImage: UIImage)
}

class SHVideoPreviewViewController: BaseViewController {

    @IBOutlet weak var playerView: UIView!
    
    var videoFileURL: NSURL?
    var thumbImage: UIImage?
    var delegate: SHVideoPreviewViewControllerDelegate?
    
    private var viewModel: SHVideoPreviewViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHVideoPreviewViewModel(viewController: self)
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
    
    @IBAction func closeButtonAction(sender: AnyObject) {
        viewModel?.closeButtonAction()
    }

    @IBAction func nextButtonAction(sender: AnyObject) {
        viewModel?.nextButtonAction()
    }
}
