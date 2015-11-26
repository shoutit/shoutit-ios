//
//  SHCreateImageCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

protocol SHCreateImageCollectionViewCellDelegate {
    func removeImage(image: UIImage)
    func removeImageURL(imageURL: String)
}

class SHCreateImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewShout: UIImageView!
    var delegate: SHCreateImageCollectionViewCellDelegate?
    
    var image: UIImage? {
        didSet {
            self.imageViewShout?.image = image
        }
    }
    
    var imageURL: String? {
        didSet {
            if let url = imageURL {
                self.imageViewShout?.setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "image_placeholder"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            }
        }
    }
    
    override func prepareForReuse() {
        self.image = nil
        self.imageURL = nil
        self.delegate = nil
        self.imageViewShout?.image = nil
    }
    
    @IBAction func removeAction(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Remove?", comment: "Remove?"), preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Cancel) { (action) in
           // Do Nothing
        }
        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            if let image = self.image, let delegate = self.delegate {
                delegate.removeImage(image)
            } else if let imageURL = self.imageURL, let delegate = self.delegate {
                delegate.removeImageURL(imageURL)
            }
        }))
        let window = UIApplication.sharedApplication().keyWindow
        window?.makeKeyAndVisible()
        window?.rootViewController = UIViewController()
        window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
       // UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
}
