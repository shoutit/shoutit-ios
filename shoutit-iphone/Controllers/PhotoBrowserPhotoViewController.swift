//
//  PhotoBrowserPhotoViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class PhotoBrowserPhotoViewController: UIViewController {
    
    var index: Int = 0
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var playButton: UIButton?
    
    var tapHandler : ((viewModel: ShoutDetailShoutImageViewModel) -> Void)!
    
    var viewModel: ShoutDetailShoutImageViewModel? {
        didSet {
            if let viewModel = viewModel {
                hydrateWithViewModel(viewModel)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let viewModel = viewModel {
            hydrateWithViewModel(viewModel)
        }
    }
    
    private func hydrateWithViewModel(viewModel: ShoutDetailShoutImageViewModel) {
        
        switch viewModel {
        case .Image(let url):
            showLoading()
            imageView?.sh_setImageWithURL(url, placeholderImage: nil, optionsInfo: nil) {[weak self] (image, error, _, _) in
                if let _ = image {
                    self?.showImage()
                } else if let error = error {
                    #if DEBUG
                    self?.showMessage(error.localizedDescription)
                    #else
                    self?.showMessage(NSLocalizedString("Could not load photos", comment: ""))
                    #endif
                }
            }
        case .Loading:
            showLoading()
        case .Error(let error):
            showMessage(error.sh_message)
        case .NoContent(let image):
            showPlaceholderImage(image)
        case .Movie(let video):
            showLoading()
            imageView?.sh_setImageWithURL(NSURL(string: video.thumbnailPath), placeholderImage: nil, optionsInfo: nil) {[weak self] (image, error, _, _) in
                if let _ = image {
                    self?.showVideo()
                } else if let error = error {
                    #if DEBUG
                        self?.showMessage(error.localizedDescription)
                    #else
                        self?.showMessage(NSLocalizedString("Could not load photos", comment: ""))
                    #endif
                }
                
            }
        }
        
    }
    
    func showMessage(message: String) {
        activityIndicator?.stopAnimating()
        activityIndicator?.hidden = true
        imageView?.hidden = true
        label?.hidden = false
        label?.text = message
        playButton?.hidden = true
    }
    
    func showPlaceholderImage(image: UIImage){
        activityIndicator?.stopAnimating()
        activityIndicator?.hidden = true
        imageView?.hidden = false
        label?.hidden = true
        playButton?.hidden = true
        imageView?.image = image
    }
    
    func showLoading() {
        imageView?.hidden = true
        label?.hidden = true
        activityIndicator?.hidden = false
        activityIndicator?.startAnimating()
        playButton?.hidden = true
    }
    
    func showImage() {
        activityIndicator?.stopAnimating()
        activityIndicator?.hidden = true
        label?.hidden = true
        imageView?.hidden = false
        playButton?.hidden = true
    }
    
    func showVideo() {
        showImage()
        playButton?.hidden = false
    }
    
    @IBAction func playAction() {
        
        guard let viewModel = viewModel else {
            return
        }
        
        tapHandler(viewModel: viewModel)
    }
}
