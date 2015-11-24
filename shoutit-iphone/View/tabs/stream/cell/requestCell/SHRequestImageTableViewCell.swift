//
//  SHRequestImageTableViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 16/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHRequestImageTableViewCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shoutImageView: UIImageView!
    @IBOutlet weak var shoutTitleLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setShout(shout: SHShout) {
        self.backView.layer.borderWidth = 0.5
        self.backView.layer.cornerRadius = 2
        self.backView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.backView.layer.shadowOffset = CGSizeMake(0, 0.5)
        self.backView.layer.masksToBounds = false
        self.backView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.backView.layer.shadowOpacity = 0.3
        self.backView.layer.shadowRadius = 1
        
        self.usernameLabel.text = shout.user?.name
        self.shoutTitleLabel.text = shout.title
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        if let number = numberFormatter.numberFromString(String(format: "%g", shout.price)) {
            let price = String(format: "%@ %@", shout.currency, number.stringValue)
            self.priceLabel.text = price
        }
        
        if let datePublished = shout.datePublished {
            self.timeLabel.text = datePublished.timeAgoSimple
        } else {
            self.timeLabel.text = "-"
        }
        
        self.locationLabel.text = shout.location?.city
        if let image = shout.user?.image {
            self.userImageView.kf_setImageWithURL(NSURL(string: image)!, placeholderImage: UIImage(named: "no_image_available"))
        }
        self.backView.layer.cornerRadius = 1.0
        if let thumbnail = shout.thumbnail where !thumbnail.isEmpty {
            self.shoutImageView.setImageWithURL(NSURL(string: thumbnail), placeholderImage: UIImage(named: "image_placeholder"), completed: nil, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        } else {
            self.shoutImageView.image = UIImage(named: "no_image_available")
        }
        self.shoutImageView.clipsToBounds = true
    }

}
