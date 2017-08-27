//
//  ShoutMediaCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 05/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ACPDownload
import RxSwift

final class ShoutMediaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var progressView : ACPDownloadView!
    @IBOutlet var editIconImageView : UIImageView?
    @IBOutlet var videoIconImageView : UIImageView!
    
    fileprivate var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
    
    func fillWith(_ attachment: MediaAttachment?) {
        
        if let attachment = attachment, let image = attachment.image {
            imageView.image = image
            editIconImageView?.isHidden = false
            videoIconImageView.hidden = attachment.type != .Video
        } else if let attachment = attachment, let thumbURL = attachment.thumbRemoteURL {
            imageView.sh_setImageWithURL(thumbURL, placeholderImage: nil)
            editIconImageView?.isHidden = false
            videoIconImageView.hidden = attachment.type != .Video
        } else {
            imageView.image = nil
            editIconImageView?.isHidden = true
            videoIconImageView.isHidden = true
        }
    }
    
    func fillWith(_ uploadTask: MediaUploadingTask?) {
        guard let task = uploadTask else {
            progressView.isHidden = true
            return
        }
        
        fillWithTaskStatus(task.status.value, attachment: task.attachment)
        
        task.progress.asDriver().drive(onNext: { [weak self] (progress) in
            self?.progressView.setProgress(progress, animated: true)
        }).addDisposableTo(disposeBag)
        
        task.status.asDriver().drive(onNext: { [weak self] (status) in
            self?.fillWithTaskStatus(status, attachment: task.attachment)
        }).addDisposableTo(disposeBag)
    }
    
    func setActive(_ active: Bool) {
        imageView.isHidden = !active
        contentView.backgroundColor = active ? UIColor(shoutitColor: .lightGreen) : UIColor(shoutitColor: .separatorGray)
    }
    
    func fillWithTaskStatus(_ status: MediaUploadingTaskStatus, attachment: MediaAttachment) {
        switch (status) {
        case .uploading:
            progressView.isHidden = false
            progressView.setIndicatorStatus(.running)
            editIconImageView?.isHidden = true
            videoIconImageView.isHidden = true
        case .error:
            progressView.isHidden = true
            progressView.setIndicatorStatus(.none)
            editIconImageView?.isHidden = false
            videoIconImageView.isHidden = true
        case .uploaded:
            progressView.isHidden = true
            editIconImageView?.isHidden = false
            videoIconImageView.hidden = attachment.type != .Video
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
