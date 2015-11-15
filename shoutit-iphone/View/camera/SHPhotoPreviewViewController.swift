//
//  SHPhotoPreviewViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

protocol SHPhotoPreviewViewControllerDelegate {
    func didPhotoPreviewFinish(image: UIImage)
}

class SHPhotoPreviewViewController: BaseViewController {

    private var viewModel: SHPhotoPreviewViewModel?
    var delegate: SHPhotoPreviewViewControllerDelegate?
    var photo: UIImage?
    
    @IBOutlet weak var photoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHPhotoPreviewViewModel(viewController: self)
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

    @IBAction func nextButtonAction(sender: AnyObject) {
        viewModel?.nextButtonAction()
    }
    
    
    @IBAction func closeButtonAction(sender: AnyObject) {
        viewModel?.closeButtonAction()
    }
}
