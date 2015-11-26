//
//  SHTopTagTableViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 17/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHTopTagTableViewCell: UITableViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var listenButton: UIButton!
    var tagCell: SHTag?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if(selected) {
            self.backgroundColor = UIColor.groupTableViewBackgroundColor()
        } else {
            self.backgroundColor = UIColor.whiteColor()
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animateWithDuration(0.1) { () -> Void in
            if(highlighted) {
                self.backgroundColor = UIColor.groupTableViewBackgroundColor()
            } else {
                self.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    func setTagCell(tag: SHTag) {
        tagCell = tag
        self.tagLabel.layer.cornerRadius = self.tagLabel.frame.size.height / 2
        self.tagLabel.layer.masksToBounds = true
        self.tagLabel.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)?.CGColor
        self.tagLabel.text = String(format: " %@ ", arguments: [tag.name])
        if let listening = self.tagCell?.isListening {
            self.setListenSelected(listening)
        }
    }
    
    func setTagCellWithName(tag: String) {
        //tagCell = tag
        setListenSelected(false)
        self.tagLabel.layer.cornerRadius = self.tagLabel.frame.size.height / 2
        self.tagLabel.layer.masksToBounds = true
        self.tagLabel.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)?.CGColor
        self.tagLabel.text = String(format: " %@ ", arguments: [tag])
        if let listening = self.tagCell?.isListening {
            self.setListenSelected(listening)
        }
    }

    
    func setListenSelected(isFollowing: Bool) {
        if(!isFollowing) {
            self.listenButton.setTitle(NSLocalizedString("Listen", comment: "Listen"), forState: UIControlState.Normal)
            self.listenButton.layer.cornerRadius = 5
            self.listenButton.layer.borderWidth = 1
            self.listenButton.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)?.CGColor
            self.listenButton.setTitleColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN), forState: UIControlState.Normal)
            self.listenButton.backgroundColor = UIColor.whiteColor()
        } else {
            self.listenButton.setTitle(NSLocalizedString("Listening", comment: "Listening"), forState: UIControlState.Normal)
            self.listenButton.layer.cornerRadius = 5
            self.listenButton.layer.borderWidth = 2
            self.listenButton.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)?.CGColor
            self.listenButton.backgroundColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
            self.listenButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }
    }
    

}
