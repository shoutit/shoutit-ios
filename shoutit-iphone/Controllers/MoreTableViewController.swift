//
//  MoreTableViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 06/09/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

enum MoreOption {
    case UseAsOwnProfile
    case ShoutitCredits
    case Pages
    case Orders
    case Settings
    case Help
    case Logout
    case InviteFriends
    case None
}

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

    
    func useAsOwnProfile() {
        Account.sharedInstance.switchToUser()
    }
    
    func showCredits() {
        self.flowDelegate?.showCreditTransactions()
    }
    
    func showPages() {
        self.flowDelegate?.showPagesList()
    }
    
    func showOrders() {
        notImplemented()
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
        notImplemented()
    }
    
    @IBAction func changeLocation() {
        self.flowDelegate?.showChangeLocation()
    }
    
    @IBAction func showMyProfile() {
        self.flowDelegate?.showEditProfile()
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if case .Some(.Page(_,_)) = Account.sharedInstance.loginState {
            if section == 2 {
                return 1.0
            }
        } else {
            if section == 0 {
                return 1.0
            }
        }
        
        return 34.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 4 {
            return 54.0
        }
        
        return 1.0
    }
    
}

extension MoreTableViewController {
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if case .Some(.Page(_,_)) = Account.sharedInstance.loginState {
                return 1
            }
            return 0
        case 1:
            return 3
        case 2:
            if case .Some(.Page(_,_)) = Account.sharedInstance.loginState {
                return 0
            }
            return 1
        case 3:
            return 2
        case 4:
            return 1
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let navigationItem = optionForIndexPath(indexPath)
        
        switch (navigationItem) {
        case .ShoutitCredits:
            self.showCredits()
        case .Pages:
            self.showPages()
        case .Orders:
            self.showOrders()
        case .InviteFriends:
            self.showInviteFriends()
        case .Settings:
            self.showSettings()
        case .Help:
            self.showHelp()
        case .Logout:
            self.logout()
        case .UseAsOwnProfile:
            self.useAsOwnProfile()
        case .None:
            break
        }
        
    }
    
    func optionForIndexPath(indexPath: NSIndexPath) -> MoreOption {
        switch (indexPath.row, indexPath.section) {
        case (0,0):
            return .UseAsOwnProfile
        case (0,1):
            return .ShoutitCredits
        case (1,1):
            return .Pages
        case (2,1):
            return .Orders
        case (0,2):
            return .InviteFriends
        case (0,3):
            return .Settings
        case (1,3):
            return .Help
        case (0,4):
            return .Logout
        default:
            return .None
        }
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
        
        creditsCountLabel?.text = "-"
    }
    
    private func fillAsGuest() {
        avatarImageView?.image = UIImage(named: "default_profile")
        nameLabel?.text = NSLocalizedString("Guest", comment: "Menu Header Title")
        coverImageView?.image = UIImage(named: "auth_screen_bg_pattern")
        
        creditsCountLabel?.text = "-"
    }
    
    private func fillLocation() {
        
        locationLabel?.text = Account.sharedInstance.locationString()
    }
}
