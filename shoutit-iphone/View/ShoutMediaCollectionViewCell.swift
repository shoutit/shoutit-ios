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
    
    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
    
    func fillWith(attachment: MediaAttachment?) {
        
        if attachment?.image != nil {
            self.imageView.image = attachment?.image
            editIconImageView?.hidden = false
        } else if attachment?.thumbRemoteURL != nil {
            self.imageView.sh_setImageWithURL(attachment?.thumbRemoteURL, placeholderImage: nil)
            editIconImageView?.hidden = false
        } else {
            self.imageView.image = nil
            editIconImageView?.hidden = true
        }
    }
    
    func fillWith(uploadTask: MediaUploadingTask?) {
        guard let task = uploadTask else {
            self.progressView.hidden = true
            return
        }
        
        fillWithTaskStatus(task.status.value)
        
        task.progress.asDriver().driveNext({ [weak self] (progress) in
            self?.progressView.setProgress(progress, animated: true)
        }).addDisposableTo(disposeBag)
        
        task.status.asDriver().driveNext { [weak self] (status) in
            self?.fillWithTaskStatus(status)
        }.addDisposableTo(disposeBag)
    }
    
    func setActive(active: Bool) {
        self.imageView.hidden = !active
        
        if active {
            self.contentView.backgroundColor = UIColor(shoutitColor: .LightGreen)
        } else {
            self.contentView.backgroundColor = UIColor(shoutitColor: .SeparatorGray)
        }
    }
    
    func fillWithTaskStatus(status: MediaUploadingTaskStatus) {
        switch (status) {
            
        case .Uploading:
            self.progressView.hidden = false
            self.progressView.setIndicatorStatus(.Running)
            self.editIconImageView?.hidden = true
            break
            
        case .Error:
            self.progressView.hidden = true
            self.progressView.setIndicatorStatus(.None)
            self.editIconImageView?.hidden = false
            break
            
        case .Uploaded:
            self.progressView.hidden = true
            self.editIconImageView?.hidden = false
            break
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
}
