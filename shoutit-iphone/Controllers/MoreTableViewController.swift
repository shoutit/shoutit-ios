//
//  MoreTableViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 06/09/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class MoreTableViewController: UITableViewController {
    
    weak var flowDelegate : FlowController?

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var creditsCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fillWith(Account.sharedInstance.loginState)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fillWith(Account.sharedInstance.loginState)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.row, indexPath.section) {
        case (0,0):
            self.showCredits()
        case (1,0):
            self.showPages()
        case (2,0):
            self.showOrders()
        case (0,1):
            self.showInviteFriends()
        case (0,2):
            self.showSettings()
        case (1,2):
            self.showHelp()
        case (0,3):
            self.logout()
        default:
            break
        }
        
    }
    
    func showCredits() {
        self.flowDelegate?.showCreditTransactions()
    }
    
    func showPages() {
        
    }
    
    func showOrders() {
        
    }
    
    func showInviteFriends() {
        self.flowDelegate?.showInviteFriends()
    }
    
    func showSettings() {
        self.flowDelegate?.showSettings()
    }
    
    func showHelp() {
        self.flowDelegate?.showHelpInterface()
    }
    
    func logout() {
        
    }
    
    @IBAction func changeLocation() {
        self.flowDelegate?.showChangeLocation()
    }
    
    @IBAction func showMyProfile() {
        self.flowDelegate?.showEditProfile()
    }
}


extension MoreTableViewController {
    func fillWith(loginState: Account.LoginState?){
        
        switch loginState {
        case .Some(.Logged(let user)):
            fillWithLoggedUser(user)
        case .Some(.Page(_, let page)):
            fillWithPage(page)
        default:
            fillAsGuest()
        }
        
        fillLocation()
    }
    
    private func fillWithLoggedUser(user: DetailedUserProfile) {
        
        if let path = user.imagePath, profileURL = NSURL(string: path) {
            avatarImageView?.sh_setImageWithURL(profileURL, placeholderImage: UIImage(named: "default_profile"))
        } else {
            avatarImageView?.image = UIImage.squareAvatarPlaceholder()
        }
        
        if let path = user.coverPath, coverURL = NSURL(string: path) {
            coverImageView?.sh_setImageWithURL(coverURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        }
        
        nameLabel?.text = user.name
        
        creditsCountLabel?.hidden = false
        creditsCountLabel?.text = "\(user.stats?.credit ?? 0)"
    }
    
    private func fillWithPage(page: DetailedProfile) {
        
        if let path = page.imagePath, profileURL = NSURL(string: path) {
            avatarImageView?.sh_setImageWithURL(profileURL, placeholderImage: UIImage(named: "default_page"))
        } else {
            avatarImageView?.image = UIImage.squareAvatarPagePlaceholder()
        }
        
        if let path = page.coverPath, coverURL = NSURL(string: path) {
            coverImageView?.sh_setImageWithURL(coverURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        }
        
        nameLabel?.text = page.name
        
        creditsCountLabel?.hidden = true
    }
    
    private func fillAsGuest() {
        avatarImageView?.image = UIImage(named: "default_profile")
        nameLabel?.text = NSLocalizedString("Guest", comment: "Menu Header Title")
        coverImageView?.image = UIImage(named: "auth_screen_bg_pattern")
        
        creditsCountLabel?.hidden = true
    }
    
    private func fillLocation() {
        
        locationLabel?.text = Account.sharedInstance.locationString()
    }
}
