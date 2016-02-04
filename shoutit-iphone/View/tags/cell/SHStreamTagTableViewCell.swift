//
//  SHStreamTagTableViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 17/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHStreamTagTableViewCell: UITableViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var lgView: UIView!
    @IBOutlet weak var listeningLabel: UILabel!
    
    var tagCell = SHTag()
    let shApiTag = SHApiTagsService()
    private var viewController: UIViewController?
    
    //var tagName: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let isListening = self.tagCell.isListening {
            self.setListenSelected(isListening)
        }
        self.tagLabel.layer.cornerRadius = self.tagLabel.frame.size.height/2
        self.tagLabel.layer.masksToBounds = true
        self.tagLabel.layer.borderColor = UIColor(shoutitColor: .ShoutDarkGreen).CGColor
        self.lgView.layer.cornerRadius = 5
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
    
    func setTagCell(tag: SHTag, viewController: UIViewController) {
        self.tagCell = tag
        self.viewController = viewController
        self.tagLabel.layer.cornerRadius = self.tagLabel.frame.size.height / 2
        self.tagLabel.layer.masksToBounds = true
        self.tagLabel.layer.borderColor = UIColor(shoutitColor: .ShoutDarkGreen).CGColor
        self.tagLabel.text = String(format: "%@", arguments: [tag.name])
        self.listeningLabel.text = "\(tag.listenersCount)"
        if let listening = self.tagCell.isListening {
            self.setListenSelected(listening)
        }
    }
    
//    func setTagCellWithName(tag: String, viewController: UIViewController) {
//        self.tagCell.name = tag
//        self.viewController = viewController
//        setListenSelected(false)
//        self.tagLabel.layer.cornerRadius = self.tagLabel.frame.size.height / 2
//        self.tagLabel.layer.masksToBounds = true
//        self.tagLabel.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)?.CGColor
//        self.tagLabel.text = String(format: "%@", arguments: [tag])
//        if let listening = self.tagCell.isListening {
//            self.setListenSelected(listening)
//        }
//    }
    
    
    func setListenSelected(isFollowing: Bool) {
        if(!isFollowing) {
            self.listenButton.setTitle(NSLocalizedString("Listen", comment: "Listen"), forState: UIControlState.Normal)
            self.listenButton.layer.cornerRadius = 5
            self.listenButton.layer.borderWidth = 1
            self.listenButton.layer.borderColor = UIColor(shoutitColor: .ShoutGreen).CGColor
            self.listenButton.setTitleColor(UIColor(shoutitColor: .ShoutGreen), forState: UIControlState.Normal)
            self.listenButton.backgroundColor = UIColor.whiteColor()
            self.listenButton.setLeftIcon(UIImage(named: "listen.png"), withSize: CGSizeMake(32, 32))
        } else {
            self.listenButton.setTitle(NSLocalizedString("Listening", comment: "Listening"), forState: UIControlState.Normal)
            self.listenButton.layer.cornerRadius = 5
            self.listenButton.layer.borderWidth = 2
            self.listenButton.layer.borderColor = UIColor(shoutitColor: .ShoutGreen).CGColor
            self.listenButton.backgroundColor = UIColor(shoutitColor: .ShoutGreen)
            self.listenButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.listenButton.setLeftIcon(UIImage(named: "listenGreen.png"), withSize: CGSizeMake(32, 32))
        }
        self.listenButton.alpha = 1
    }
    
    @IBAction func listenAction(sender: AnyObject) {
        //[self setListenSelected:self.model.tag.is_listening];
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        indicatorView.frame = self.listenButton.frame
        indicatorView.startAnimating()
        self.listenButton.hidden = true
        self.listenButton.superview?.addSubview(indicatorView)
        if let boolListen = self.tagCell.isListening == nil ? false : self.tagCell.isListening {
            self.setListenSelected(boolListen)
            if(boolListen) {
                self.listeningLabel.text = "\(--self.tagCell.listenersCount)"
                shApiTag.unfollowTag(self.tagCell.name, completionHandler: { (response) -> Void in
                    switch(response.result) {
                    case .Success( _):
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tagCell.isListening = false
                            self.setListenSelected(false)
                            indicatorView.removeFromSuperview()
                            self.listenButton.hidden = false
                           // self.tagCell.listenersCount--
                        })
                    case .Failure(let error):
                        log.error("Error deleting tags \(error.localizedDescription)")
                        indicatorView.removeFromSuperview()
                        self.listenButton.hidden = false
                    }
                })
            } else {
                self.listeningLabel.text = "\(++self.tagCell.listenersCount)"
                shApiTag.followTag(self.tagCell.name, completionHandler: { (response) -> Void in
                    switch(response.result) {
                    case .Success( _):
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tagCell.isListening = true
                            self.setListenSelected(true)
                            indicatorView.removeFromSuperview()
                            self.listenButton.hidden = false
                           // self.tagCell.listenersCount++
                        })
                    case .Failure(let error):
                        log.error("Error listening to tags \(error.localizedDescription)")
                    }
                })
            }
        }
    }
    
    @IBAction func listenersAction(sender: AnyObject) {
        let listViewController = UIStoryboard.getProfile().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHUSERLIST) as! SHUserListTableViewController
        listViewController.requestUsersForTag(self.tagCell.name)
        viewController?.navigationController?.pushViewController(listViewController, animated: true)
    }
    
}
