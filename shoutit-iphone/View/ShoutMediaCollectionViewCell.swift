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
        self.imageView.image = attachment?.image
    }
    
    func fillWith(uploadTask: MediaUploadingTask?) {
        guard let task = uploadTask else {
            self.progressView.hidden = true
            return
        }
        
        self.progressView.hidden = false
        
        switch (task.status) {
        case .Uploading:
            self.progressView.setIndicatorStatus(.Running)
            
            task.progress.asDriver().driveNext({ (progress) -> Void in
                self.progressView.setProgress(progress, animated: true)
            }).addDisposableTo(disposeBag)
        case .Error:
            self.progressView.setIndicatorStatus(.None)
        case .Uploaded:
            self.progressView.setIndicatorStatus(.Running)
            self.progressView.setProgress(1.0, animated: true)
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
}
