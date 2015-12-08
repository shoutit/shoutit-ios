//
//  SHMessagesViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 30/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import URBMediaFocusViewController

class SHMessagesViewController: JSQMessagesViewController, UIActionSheetDelegate {
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    var isFromShout = false
    var shout: SHShout?
    var myUser: SHUser?
    var mediaVideoController: URBMediaFocusViewController?
    var refreshIndicatorView: UIActivityIndicatorView?
    var progress: UIProgressView?
    var progressTimer: NSTimer?
    var statusCheckerTimer: NSTimer?
    var conversationID: String?
    var typingTimer: NSTimer?
    var typingCounter = 0
    private var viewModel: SHMessagesViewModel?
    private var progressView: UIProgressView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewModel()
        self.mediaVideoController = URBMediaFocusViewController()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleCollectionTapRecognizer:"))
        self.collectionView?.dataSource = viewModel
        self.collectionView?.delegate = viewModel
        self.collectionView?.addGestureRecognizer(tapRecognizer)
        self.myUser = SHOauthToken.getFromCache()?.user
        self.senderId = myUser?.username
        self.senderDisplayName = myUser?.name
        var size = self.view.frame.size
        if let tabBarCtrl = self.tabBarController {
            let tsize = tabBarCtrl.tabBar.frame.size
            size.height -= min(tsize.width, tsize.height)
        }
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, size.width, size.height)
        if(self.isFromShout) {
            let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("doneAction"))
            self.navigationItem.leftBarButtonItem = item
        }
        self.automaticallyScrollsToMostRecentMessage = true
        self.refreshIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        self.refreshIndicatorView?.startAnimating()
//        let cellNib = UINib(nibName: Constants.CollectionViewCell.SHMessageShoutOutgoingCollectionViewCell, bundle: nil)
//        self.collectionView?.registerNib(cellNib, forCellWithReuseIdentifier: Constants.CollectionViewCell.SHMessageShoutOutgoingCollectionViewCell)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapTitleAction"))
        let titleLabel = UILabel()
        titleLabel.text = self.title
        titleLabel.font = UIFont.boldSystemFontOfSize(17)
        titleLabel.sizeToFit()
        titleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        titleLabel.userInteractionEnabled = true
        titleLabel.addGestureRecognizer(tapGesture)
        self.navigationItem.titleView = titleLabel
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedMessage:", name: "kMessagePushNotification", object: nil)
        self.collectionView?.collectionViewLayout.messageBubbleFont = UIFont(name: "Helvetica", size: 15.0)
        self.scrollToBottomAnimated(false)
        if(!self.isFromShout) {
            self.setupNavigationBar()
        }
        
        if let navBar = self.navigationController?.navigationBar.topItem {
            navBar.title = NSLocalizedString("Back", comment: "Back")
        }
        viewModel?.viewDidLoad()
    }
    
    func initializeViewModel() {
        viewModel = SHMessagesViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView?.collectionViewLayout.springinessEnabled = true
        viewModel?.viewDidAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupProgressBar()
        if(!self.isFromShout) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("deleteMessage:"), name: "DeleteMessageNotification", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textDidChange:"), name: UITextViewTextDidChangeNotification, object: nil)
        }
        viewModel?.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.inputToolbar?.contentView?.textView?.resignFirstResponder()
        self.progress?.removeFromSuperview()
        if(!self.isFromShout) {
            self.finishCheckingStatus()
        }
        self.progress = nil
        viewModel?.viewWillDisappear()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if(!self.isFromShout) {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "DeleteMessageNotification", object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidChangeNotification, object: nil)
            if var timer = self.typingTimer {
                timer.invalidate()
            }
        }
        viewModel?.viewDidDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshAction(sender: AnyObject) {
        if let conversationID = self.conversationID {
            self.viewModel?.getMessagesById(conversationID)
        }
    }
    
    func finishCheckingStatus() {
        if let checkerTimer = self.statusCheckerTimer {
            checkerTimer.invalidate()
        }
        self.statusCheckerTimer = nil
    }
    
    func textDidChange() {
        if(self.typingTimer == nil) {
            self.typingTimer = NSTimer(timeInterval: 1, target: self, selector: Selector("typingAction"), userInfo: nil, repeats: true)
            //[self.conversationManager sendTyping:[[SHLoginModel sharedModel]selfUser]];
        }
    }
    
    func typingAction() {
        if(self.typingCounter < 3) {
            self.typingCounter++
        } else {
            self.typingCounter = 0
            self.typingTimer?.invalidate()
            self.typingTimer = nil
        }
    }
    
    func receivedMessage (notification: NSNotification) {
        self.viewModel?.receivedMessage(notification)
    }
    
    func setupNavigationBar () {
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.darkTextColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(17)
        titleLabel.text = self.title
        titleLabel.sizeToFit()
        
        let subTitleLabel = UILabel(frame: CGRectMake(0, 22, 0, 0))
        subTitleLabel.textAlignment = NSTextAlignment.Center
        subTitleLabel.backgroundColor = UIColor.clearColor()
        subTitleLabel.textColor = UIColor.whiteColor()
        subTitleLabel.font = UIFont.systemFontOfSize(12)
        //[self checkStaus];
        subTitleLabel.text = "offline"
        subTitleLabel.sizeToFit()
        
        let twoLineTitleView = UIView(frame: CGRectMake(0, 0, max(subTitleLabel.frame.size.width, titleLabel.frame.size.width), 30))
        twoLineTitleView.addSubview(titleLabel)
        twoLineTitleView.addSubview(subTitleLabel)
        
        let widthDiff = subTitleLabel.frame.size.width - titleLabel.frame.size.width
        if(widthDiff > 0) {
            var frame = titleLabel.frame
            frame.origin.x = widthDiff / 2
            titleLabel.frame = CGRectIntegral(frame)
        } else {
            var frame = subTitleLabel.frame
            frame.origin.x = abs(widthDiff) / 2
            subTitleLabel.frame = CGRectIntegral(frame)
        }
        self.navigationItem.titleView = twoLineTitleView
    }
    
    func setupProgressBar () {
        if let navBar = self.navigationController?.navigationBar {
            if((self.progress == nil)) {
                self.progress = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
                self.progress?.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
                self.progress?.backgroundColor = navBar.window?.tintColor
                self.progress?.progressTintColor = UIColor.jsq_messageBubbleBlueColor()
                self.progress?.frame = CGRectMake(0, navBar.frame.size.height - 20, navBar.frame.size.width, 2)
                if let progress = self.progress {
                    navBar.addSubview(progress)
                }
            } else {
                
            }
            self.progress?.setProgress(0, animated: false)
        }
    }
    
    func startProgress () {
        self.progressTimer = NSTimer(timeInterval: 0.5, target: self, selector: Selector("increaseProgress:"), userInfo: nil, repeats: true)
    }
    
    func resetProgress () {
        self.progress?.setProgress(0, animated: true)
    }
    
    func finishProgress () {
        self.progressTimer?.invalidate()
        self.progressTimer = nil
        self.progress?.setProgress(1, animated: true)
        self.performSelector(Selector("resetProgress"), withObject: nil, afterDelay: 1)
    }
    
    func increaseProgress () {
        if let _ = self.progressTimer, let progressView = self.progressView {
            if(progressView.progress < 0.5) {
                var p = progressView.progress
                p += 0.1
                self.progressView?.setProgress(p, animated: true)
                
            } else if (progressView.progress < 0.6) {
                var p = progressView.progress
                p += 0.02
                self.progressView?.setProgress(p, animated: true)
            } else {
                self.progressTimer?.invalidate()
            }
        }
    }
    
    
    func doneAction () {
        let transition = CATransition()
        transition.duration = 0.1
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromBottom
        self.navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    // JSQMessagesViewController method overrides
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        viewModel?.sendButtonAction(text)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        var options = [NSLocalizedString("Photo or Video", comment: "Photo or Video"), NSLocalizedString("Select a Shout", comment: "Select a Shout"), NSLocalizedString("My Location", comment: "My Location")]
        if let shout = self.shout {
            if(shout.user?.username == SHOauthToken.getFromCache()?.user?.username) {
                options.append(NSLocalizedString("Shout Location", comment: "Shout Location"))
            }
        }
        let sheet = UIActionSheet(title: NSLocalizedString("Post a shout", comment: "Post a shout"), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"), destructiveButtonTitle: nil)
        for title in options {
            sheet.addButtonWithTitle(title)
        }
        if let inputToolbar = self.inputToolbar {
            sheet.showFromToolbar(inputToolbar)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        viewModel?.actionWithButtonIndex(actionSheet, buttonIndex: buttonIndex)
    }
    
    func handleCollectionTapRecognizer (recognizer: UITapGestureRecognizer) {
        if(recognizer.state == UIGestureRecognizerState.Ended) {
            if let textView = self.inputToolbar?.contentView?.textView {
                if(textView.isFirstResponder()) {
                    self.inputToolbar?.contentView?.textView?.resignFirstResponder()
                }
            }
        }
    }
    
    func startCheckingStatus () {
        self.statusCheckerTimer = NSTimer(timeInterval: 10, target: self, selector: Selector("checkStaus"), userInfo: nil, repeats: true)
    }
    
    func deleteMessage(aNotification: NSNotification) {
        self.viewModel?.deleteMessage(aNotification)
    }
    
    func tapTitleAction () {
        self.viewModel?.tapTitleAction()
    }
    
    deinit {
        viewModel?.destroy()
    }
}
