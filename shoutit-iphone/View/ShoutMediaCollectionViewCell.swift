//
//  ShoutMediaCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 05/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ShoutMediaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView : UIImageView!
    
    func fillWith(attachment: MediaAttachment?) {
        self.imageView.image = attachment?.image
    }
}
