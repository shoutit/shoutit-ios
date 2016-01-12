//
//  SHUserTableViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 11/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var user: SHUser?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUser(user: SHUser) {
        self.user = user
        self.nameLabel.text = user.name
        if let imageUrl = self.user?.image {
            self.userImageView.setImageWithURL(NSURL(string: imageUrl), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        }
        self.userImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.borderColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor
        self.userImageView.layer.borderWidth = 1.0
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2.0
    }

}
