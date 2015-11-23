//
//  SHShoutCalloutView.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 18/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class SHShoutCalloutView: UIView {
    
    @IBOutlet weak var imageViewShout: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    private var accessoryBlock: ((shout: SHShout) -> ())? = nil
    
    var shout: SHShout?
    
    static func loadViewFromNib() -> SHShoutCalloutView {
        return NSBundle.mainBundle().loadNibNamed("SHShoutCalloutView", owner: self, options: nil).last as! SHShoutCalloutView
    }
    
    @IBAction func action(sender: AnyObject) {
        if let shout = self.shout {
            self.accessoryBlock?(shout: shout)
        }
    }
    
    func setShout(shout: SHShout, withAccessoryBlock: (shout: SHShout) -> ()) {
        self.accessoryBlock = withAccessoryBlock
        self.shout = shout
        if !shout.thumbnail.isEmpty {
            self.imageViewShout.setImageWithURL(NSURL(string: shout.thumbnail), placeholderImage: UIImage(named: "image_placeholder"), completed: { (image, error, cacheType, url) -> Void in
                // Do Nothing
                }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        } else {
            self.imageViewShout.image = UIImage(named: "no_image_available")
        }
        self.imageViewShout.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageViewShout.clipsToBounds = true
        self.imageViewShout.layer.cornerRadius = self.imageViewShout.frame.size.width / 15.0
        let imgMask = UIImage(named: "shoutMask")
        let mask = CALayer()
        mask.contents = imgMask?.CGImage
        mask.frame = CGRectMake(0, 0, self.imageViewShout.frame.size.width, self.imageViewShout.frame.size.height)
        self.imageViewShout.layer.mask = mask
        self.imageViewShout.layer.masksToBounds = true
        
        if shout.datePublished > 0 {
            self.timeLabel.text = NSDate(timeIntervalSince1970: shout.datePublished).timeAgoSimple
        } else {
            self.timeLabel.text = "-"
        }
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        if let number = numberFormatter.numberFromString(String(format: "%g", shout.price)) {
            let price = String(format: "%@ %@", shout.currency, number.stringValue)
            self.priceLabel.text = price
        }
        
        self.descriptionLabel.text = shout.text
        self.titleLabel.text = shout.title
    }

}
