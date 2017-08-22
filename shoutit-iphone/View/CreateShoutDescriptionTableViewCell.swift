//
//  CreateShoutDescriptionTableViewCell.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class CreateShoutDescriptionTableViewCell: UITableViewCell {

    fileprivate var borderedView : UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     
        self.layoutMargins = UIEdgeInsetsMake(0, 30.0, 0, 30.0)
        
        borderedView = UIView(frame: CGRect(x: 20, y: 1, width: self.bounds.width - 40.0, height: self.bounds.height - 2))
        
        guard let borderedView = borderedView else { return }
        
        borderedView.layer.borderWidth = 1.0
        borderedView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        borderedView.layer.cornerRadius = 5.0
        borderedView.isUserInteractionEnabled = false
        borderedView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(borderedView, belowSubview: self.contentView)
        
        let imageView = UIImageView(image: UIImage.rightBlueArrowDisclosureIndicator())
        imageView.isUserInteractionEnabled = false
        self.accessoryView = imageView
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderedView?.frame = CGRect(x: 20, y: 1, width: self.bounds.width - 40.0, height: self.bounds.height - 2)
    }
    
}
