//
//  MenuHeaderView.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 05/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Kingfisher

class MenuHeaderView: UIView {
    
    @IBOutlet weak var profileImageView : UIImageView?
    @IBOutlet weak var coverImageView: UIImageView?
    @IBOutlet weak var profileNameLabel : UILabel?
    
    @IBOutlet weak var countryNameLabel : UILabel?
    @IBOutlet weak var countryFlagImageView : UIImageView?
    
    @IBOutlet weak var createShoutButton : UIButton?
    @IBOutlet weak var changeCountryButton : UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profileNameLabel?.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.profileNameLabel?.layer.shadowRadius = 1
        self.profileNameLabel?.layer.shadowOpacity = 0.5;
    }
    
    func fillWith(user: User?){
        
        if let user = user as? LoggedUser {
            if let path = user.imagePath, profileURL = NSURL(string: path) {
                profileImageView?.kf_setImageWithURL(profileURL, placeholderImage: UIImage(named: "guest avatar"))
            }
            
            profileNameLabel?.text = user.name
        } else {
            fillAsGuest()
        }
        
        fillLocation()
    }
    
    func fillAsGuest() {
        profileImageView?.image = UIImage(named: "guest avatar")
        profileNameLabel?.text = NSLocalizedString("Guest", comment: "")
    }
    
    func fillLocation() {
        
        countryNameLabel?.text = Account.sharedInstance.locationString()
        
        if let flagName = Account.sharedInstance.user?.location.country {
            countryFlagImageView?.hidden = false
            countryFlagImageView?.image = UIImage(named: flagName)
        } else {
            countryFlagImageView?.hidden = true
        }
    }
    
}
