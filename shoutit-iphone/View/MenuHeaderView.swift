//
//  MenuHeaderView.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 05/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Kingfisher
import ShoutitKit

final class MenuHeaderView: UIView {
    
    @IBOutlet weak var profileImageView : UIImageView?
    @IBOutlet weak var coverImageView: UIImageView?
    @IBOutlet weak var profileNameLabel : UILabel?
    
    @IBOutlet weak var countryNameLabel : UILabel?
    @IBOutlet weak var countryFlagImageView : UIImageView?
    
    @IBOutlet weak var createShoutButton : UIButton?
    @IBOutlet weak var changeCountryButton : UIButton?
    @IBOutlet weak var creditsCountLabel : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profileNameLabel?.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.profileNameLabel?.layer.shadowRadius = 1
        self.profileNameLabel?.layer.shadowOpacity = 0.5;
    }
    
    func fillWith(_ loginState: Account.LoginState?){
        
        switch loginState {
        case .some(.logged(let user)):
            fillWithLoggedUser(user)
        case .some(.page(_, let page)):
            fillWithPage(page)
        default:
            fillAsGuest()
        }
        
        fillLocation()
    }
    
    fileprivate func fillWithLoggedUser(_ user: DetailedUserProfile) {
        
        if let path = user.imagePath, let profileURL = URL(string: path) {
            profileImageView?.sh_setImageWithURL(profileURL, placeholderImage: UIImage(named: "default_profile"))
        } else {
            profileImageView?.image = UIImage.squareAvatarPlaceholder()
        }
        
        if let path = user.coverPath, let coverURL = URL(string: path) {
            coverImageView?.sh_setImageWithURL(coverURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        }
        
        profileNameLabel?.text = user.name
        
        profileImageView?.layer.borderColor = UIColor.white.cgColor
        profileImageView?.layer.borderWidth = 1.0
        profileImageView?.layer.masksToBounds = true
        
        creditsCountLabel?.isHidden = false
        creditsCountLabel?.text = "\(user.stats?.credit ?? 0)"
    }
    
    fileprivate func fillWithPage(_ page: DetailedProfile) {
        
        if let path = page.imagePath, let profileURL = URL(string: path) {
            profileImageView?.sh_setImageWithURL(profileURL, placeholderImage: UIImage(named: "default_page"))
        } else {
            profileImageView?.image = UIImage.squareAvatarPagePlaceholder()
        }
        
        if let path = page.coverPath, let coverURL = URL(string: path) {
            coverImageView?.sh_setImageWithURL(coverURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        }
        
        profileNameLabel?.text = page.name
        
        profileImageView?.layer.borderColor = UIColor.white.cgColor
        profileImageView?.layer.borderWidth = 1.0
        profileImageView?.layer.masksToBounds = true
        
        creditsCountLabel?.isHidden = true
    }
    
    fileprivate func fillAsGuest() {
        profileImageView?.image = UIImage(named: "default_profile")
        profileNameLabel?.text = NSLocalizedString("Guest", comment: "Menu Header Title")
        coverImageView?.image = UIImage(named: "auth_screen_bg_pattern")
        
        profileImageView?.layer.borderColor = UIColor.white.cgColor
        profileImageView?.layer.borderWidth = 0.0
        profileImageView?.layer.masksToBounds = true
        
        creditsCountLabel?.isHidden = true
    }
    
    fileprivate func fillLocation() {
        
        countryNameLabel?.text = Account.sharedInstance.locationString()
        
        if let flagName = Account.sharedInstance.user?.location.country {
            countryFlagImageView?.isHidden = false
            countryFlagImageView?.image = UIImage(named: flagName)
        } else {
            countryFlagImageView?.isHidden = true
        }
    }
    
}
