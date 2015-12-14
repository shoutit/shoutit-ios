//
//  SHShoutSquerCollectionViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 28/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutSquareCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewShout: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    

    func setShout(shout: SHShout) {
        if let shoutThumbnail = shout.thumbnail where shoutThumbnail != ""{
            self.imageViewShout.setImageWithURL(NSURL(string: shoutThumbnail), placeholderImage: UIImage(named: "image_placeholder"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        } else {
            self.imageViewShout.image = UIImage(named: "no_image_available_thumb")
        }
        self.imageViewShout.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageViewShout.clipsToBounds = true
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        if let number = numberFormatter.numberFromString(String(format: "%g", shout.price)) {
            let price = String(format: "%@ %@", shout.currency, number.stringValue)
            self.priceLabel.text = price
        }
        self.titleLabel.text = shout.title
        self.layer.cornerRadius = self.frame.size.width / 50.0
    }
}
