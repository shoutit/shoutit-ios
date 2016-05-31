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
    
    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
    
    func fillWith(attachment: MediaAttachment?) {
        
        if let attachment = attachment, image = attachment.image {
            imageView.image = image
            editIconImageView?.hidden = false
            videoIconImageView.hidden = attachment.type != .Video
        } else if let attachment = attachment, thumbURL = attachment.thumbRemoteURL {
            imageView.sh_setImageWithURL(thumbURL, placeholderImage: nil)
            editIconImageView?.hidden = false
            videoIconImageView.hidden = attachment.type != .Video
        } else {
            imageView.image = nil
            editIconImageView?.hidden = true
            videoIconImageView.hidden = true
        }
    }
    
    func fillWith(uploadTask: MediaUploadingTask?) {
        guard let task = uploadTask else {
            progressView.hidden = true
            return
        }
        
        fillWithTaskStatus(task.status.value, attachment: task.attachment)
        
        task.progress.asDriver().driveNext{ [weak self] (progress) in
            self?.progressView.setProgress(progress, animated: true)
        }.addDisposableTo(disposeBag)
        
        task.status.asDriver().driveNext { [weak self] (status) in
            self?.fillWithTaskStatus(status, attachment: task.attachment)
        }.addDisposableTo(disposeBag)
    }
    
    func setActive(active: Bool) {
        imageView.hidden = !active
        contentView.backgroundColor = active ? UIColor(shoutitColor: .LightGreen) : UIColor(shoutitColor: .SeparatorGray)
    }
    
    func fillWithTaskStatus(status: MediaUploadingTaskStatus, attachment: MediaAttachment) {
        switch (status) {
        case .Uploading:
            progressView.hidden = false
            progressView.setIndicatorStatus(.Running)
            editIconImageView?.hidden = true
            videoIconImageView.hidden = true
        case .Error:
            progressView.hidden = true
            progressView.setIndicatorStatus(.None)
            editIconImageView?.hidden = false
            videoIconImageView.hidden = true
        case .Uploaded:
            progressView.hidden = true
            editIconImageView?.hidden = false
            videoIconImageView.hidden = attachment.type != .Video
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
