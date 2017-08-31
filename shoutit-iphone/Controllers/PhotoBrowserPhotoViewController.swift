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
    
    var tapHandler : ((_ viewModel: ShoutDetailShoutImageViewModel) -> Void)!
    
    var viewModel: ShoutDetailShoutImageViewModel? {
        didSet {
            if let viewModel = viewModel {
                hydrateWithViewModel(viewModel)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let viewModel = viewModel {
            hydrateWithViewModel(viewModel)
        }
    }
    
    fileprivate func hydrateWithViewModel(_ viewModel: ShoutDetailShoutImageViewModel) {
        
        switch viewModel {
        case .image(let url):
            showLoading()
            imageView?.sh_setImageWithURL(url, placeholderImage: nil, optionsInfo: nil) {[weak self] (image, error, _, _) in
                if let _ = image {
                    self?.showImage()
                } else if let error = error {
                    #if DEBUG
                    self?.showMessage(error.localizedDescription)
                    #else
                    self?.showMessage(NSLocalizedString("Could not load photos", comment: "Photo Browser Error Message"))
                    #endif
                }
            }
        case .loading:
            showLoading()
        case .error(let error):
            showMessage(error.sh_message)
        case .noContent(let image):
            showPlaceholderImage(image)
        case .movie(let video):
            showLoading()
            imageView?.sh_setImageWithURL(URL(string: video.thumbnailPath), placeholderImage: nil, optionsInfo: nil) {[weak self] (image, error, _, _) in
                if let _ = image {
                    self?.showVideo()
                } else if let error = error {
                    #if DEBUG
                        self?.showMessage(error.localizedDescription)
                    #else
                        self?.showMessage(NSLocalizedString("Could not load photos", comment: "Photo Browser Error Message"))
                    #endif
                    
                }
                
            }
        }
        
    }
    
    func showMessage(_ message: String) {
        activityIndicator?.stopAnimating()
        activityIndicator?.isHidden = true
        imageView?.isHidden = true
        label?.isHidden = false
        label?.text = message
        playButton?.isHidden = true
    }
    
    func showPlaceholderImage(_ image: UIImage){
        activityIndicator?.stopAnimating()
        activityIndicator?.isHidden = true
        imageView?.isHidden = false
        label?.isHidden = true
        playButton?.isHidden = true
        imageView?.image = image
    }
    
    func showLoading() {
        imageView?.isHidden = true
        label?.isHidden = true
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
        playButton?.isHidden = true
    }
    
    func showImage() {
        activityIndicator?.stopAnimating()
        activityIndicator?.isHidden = true
        label?.isHidden = true
        imageView?.isHidden = false
        playButton?.isHidden = true
    }
    
    func showVideo() {
        showImage()
        playButton?.isHidden = false
    }
    
    @IBAction func playAction() {
        
        guard let viewModel = viewModel else {
            return
        }
        
        tapHandler(viewModel)
    }
}
