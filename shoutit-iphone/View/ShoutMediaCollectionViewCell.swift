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

class ShoutMediaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var progressView : ACPDownloadView!
    
    private var disposeBag = DisposeBag()
    
    func fillWith(attachment: MediaAttachment?) {
        
        if attachment?.image != nil {
            self.imageView.image = attachment?.image
        } else if attachment?.thumbRemoteURL != nil {
            self.imageView.sh_setImageWithURL(attachment?.thumbRemoteURL, placeholderImage: nil)
        } else {
            self.imageView.image = nil
            
        }
    }
    
    func fillWith(uploadTask: MediaUploadingTask?) {
        guard let task = uploadTask else {
            self.progressView.hidden = true
            return
        }
        
        fillWithTaskStatus(task.status.value)
        
        task.progress.asDriver().driveNext({ [weak self] (progress) -> Void in
            self?.progressView.setProgress(progress, animated: true)
        }).addDisposableTo(disposeBag)
        
        task.status.asDriver().driveNext { [weak self] (status) -> Void in
            self?.fillWithTaskStatus(status)
        }.addDisposableTo(disposeBag)
    }
    
    func fillWithTaskStatus(status: MediaUploadingTaskStatus) {
        switch (status) {
            
        case .Uploading:
            self.progressView.hidden = false
            self.progressView.setIndicatorStatus(.Running)
            break
            
        case .Error:
            self.progressView.hidden = true
            self.progressView.setIndicatorStatus(.None)
            break
            
        case .Uploaded:
            self.progressView.hidden = true
            break
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
}
