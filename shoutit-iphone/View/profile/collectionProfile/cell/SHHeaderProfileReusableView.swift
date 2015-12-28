//
//  SHHeaderProfileReusableView.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 28/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

protocol SHHeaderProfileReusableViewDelegate {
    func didPressListenersButton(button: UIButton)
    func didPressListeningButton(button: UIButton)
    func didPressTagsButton(button: UIButton)
    func didPressCvShortcutButtonButton(button: UIButton)
}

class SHHeaderProfileReusableView: UICollectionReusableView {

    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var cvShortcutButton: UIButton!
    @IBOutlet weak var lgView: UIView!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var listenersButton: UIButton!
    @IBOutlet weak var listenersNumberLabel: UILabel!
    @IBOutlet weak var listeningButton: UIButton!
    @IBOutlet weak var listeningNumberLabel: UILabel!
    @IBOutlet weak var listeningTagsLabel: UILabel!
    @IBOutlet weak var lsView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var tgView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    var delegate: SHHeaderProfileReusableViewDelegate?
    
    private var imglisten: UIImageView?
    private var imglistenGreen: UIImageView?
    private var user: SHUser?
    var viewController: SHProfileCollectionViewController?
    var shApiUser = SHApiUserService()
    
    override func awakeFromNib() {
        self.lgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("showListeningAction:")))
        self.lsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("showListnersAction:")))
        self.tgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("tagsScreen:")))
    }
    
    func setupViewForUser (user: SHUser, viewController: SHProfileCollectionViewController) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.viewController = viewController
            self.loadUserData(user)
            self.imglisten = UIImageView(frame: CGRectMake(0, 0, 32, 32))
            self.imglisten?.image = UIImage(named: "listen")
            self.imglistenGreen = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
            self.imglistenGreen?.image = UIImage(named: "listenGreen")
            
            self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
            self.profileImageView.clipsToBounds = true
            self.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
            self.profileImageView.layer.borderWidth = 2.0
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2.0
            
            
            if(user.username == SHOauthToken.getFromCache()?.user?.username) {
                self.listenButton.hidden = true
                self.cvShortcutButton.hidden = false
                self.cvShortcutButton.layer.cornerRadius = 5
                self.cvShortcutButton.backgroundColor = UIColor.lightTextColor()
            } else {
                if let isListen = self.user?.isListening {
                    self.setListenSelected(isListen)
                }
            }
            
            self.lgView.layer.cornerRadius = 5
            self.lsView.layer.cornerRadius = 5
            self.tgView.layer.cornerRadius = 5
        }
    }
    
    func setListenSelected (isFollowing: Bool) {
        if(!isFollowing) {
            self.listenButton.setTitle(NSLocalizedString("Listen", comment: "Listen"), forState: UIControlState.Normal)
            self.listenButton.layer.cornerRadius = 5
            self.listenButton.layer.borderWidth = 1
            self.listenButton.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)?.CGColor
            self.listenButton.setTitleColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN), forState: UIControlState.Normal)
            self.listenButton.backgroundColor = UIColor.groupTableViewBackgroundColor()
            self.imglisten?.removeFromSuperview()
            if let imageListen = self.imglisten {
                self.listenButton.addSubview(imageListen)
            }
            self.listenButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 28.0, 0.0, 0)
        } else {
            self.imglistenGreen?.removeFromSuperview()
            if let imageListenGreen = self.imglistenGreen {
                self.listenButton.addSubview(imageListenGreen)
            }
            self.listenButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 28.0, 0.0, 0)
            self.listenButton.setTitle(NSLocalizedString("Listening", comment: "Listening"), forState: UIControlState.Normal)
            self.listenButton.layer.cornerRadius = 5
            self.listenButton.layer.borderWidth = 2
            self.listenButton.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)?.CGColor
            self.listenButton.backgroundColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
            self.listenButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func cvShortcut(sender: AnyObject) {
        if let delegate = self.delegate, let button = sender as? UIButton {
            delegate.didPressCvShortcutButtonButton(button)
        }
    }
    
    @IBAction func listenAction(sender: AnyObject) {
        if(SHOauthToken.getFromCache()?.accessToken?.characters.count < 0) {
            SHOauthToken.goToLogin()
            SHProgressHUD.showError(NSLocalizedString("Please log in to continue", comment: "Please log in to continue"))
            return
        }
        if let isFollowing = self.user?.isFollowing {
            self.setListenSelected(isFollowing)
        }
        if let user = self.user {
            if(user.username != SHOauthToken.getFromCache()?.user?.username) {
                let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
                indicatorView.frame = self.listeningButton.frame
                indicatorView.startAnimating()
                self.listenButton.hidden = true
                self.listeningButton.superview?.addSubview(indicatorView)
                if let isFollowing = user.isFollowing == nil ? false : user.isFollowing {
                    if(isFollowing) {
                        if let username = user.username {
                            shApiUser.unfollowUser(username, completionHandler: { (response) -> Void in
                                switch(response.result) {
                                case .Success( _):
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.user?.isFollowing = false
                                        self.setListenSelected(false)
                                        indicatorView.removeFromSuperview()
                                        self.listenButton.hidden = false
                                        user.listenersCount--
                                    })
                                case .Failure(let error):
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        log.error("Unable to listen to the user \(error.localizedDescription)")
                                        indicatorView.removeFromSuperview()
                                        self.listenButton.hidden = false
                                    })
                                }
                            })
                        }
                    } else {
                        if let username = user.username {
                            shApiUser.followUser(username, completionHandler: { (response) -> Void in
                                switch(response.result) {
                                case .Success( _):
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.user?.isFollowing = true
                                        self.setListenSelected(true)
                                        indicatorView.removeFromSuperview()
                                        self.listenButton.hidden = false
                                        user.listenersCount++
                                    })
                                case .Failure(let error):
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        log.error("Unable to listen to the user \(error.localizedDescription)")
                                        indicatorView.removeFromSuperview()
                                        self.listenButton.hidden = false
                                    })
                                }
                            })
                        }
                    }
                }
                
            }
        }
    }
    
    @IBAction func showListnersAction(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.didPressListenersButton(listenersButton)
        }
    }
    
    @IBAction func showListeningAction(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.didPressListeningButton(listeningButton)
        }
    }
    
    @IBAction func tagsScreen(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.didPressTagsButton(tagButton)
        }
    }
    
    private func loadUserData(user: SHUser) {
        if let username = user.username {
            shApiUser.loadUserDetails(username, cacheResponse: { (shUser) -> Void in
                self.fillUserDetails(shUser)
                }) { (response) -> Void in
                    switch(response.result) {
                    case .Success(let result):
                        self.fillUserDetails(result)
                    case .Failure(let error):
                        log.error("Error getting user details \(error.localizedDescription)")
                    }
            }
        }
    }
    
    private func fillUserDetails(shUser: SHUser) {
        self.user = shUser
        self.nameLabel.text = self.user?.name
        self.bioTextView.text = self.user?.bio
        if let userImage = self.user?.image {
            self.profileImageView.setImageWithURL(NSURL(string: userImage), placeholderImage: UIImage(named: "no_image_available"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        }
        if let image = self.user?.image {
            self.blurredImageView.sd_setImageWithURL(NSURL(string: image))
        }
        
        self.listenersNumberLabel.text = "\(shUser.listenersCount)"
        if let users = shUser.listeningCount?.users, let tags = shUser.listeningCount?.tags {
            self.listeningNumberLabel.text = "\(users)"
            self.listeningTagsLabel.text = "\(tags)"
        }
    }
    
    
}
