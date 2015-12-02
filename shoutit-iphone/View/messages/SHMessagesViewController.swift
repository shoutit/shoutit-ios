//
//  SHMessagesViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 30/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class SHMessagesViewController: JSQMessagesViewController {
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    var isFromShout = false
    var shout: SHShout?
    
    private var viewModel: SHMessagesViewModel?
    private var progressView: UIProgressView?
    private var progressTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleCollectionTapRecognizer:"))
        self.collectionView?.addGestureRecognizer(tapRecognizer)
        var size = self.view.frame.size
        if let tabBarCtrl = self.tabBarController {
            let tsize = tabBarCtrl.tabBar.frame.size
            size.height -= min(tsize.width, tsize.height)
        }
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, size.width, size.height)
        if(self.isFromShout) {
            let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("doneAction:"))
            self.navigationItem.leftBarButtonItem = item
        }
        
        let cellNib = UINib(nibName: Constants.CollectionViewCell.SHMessageShoutOutgoingCollectionViewCell, bundle: nil)
        self.collectionView?.registerNib(cellNib, forCellWithReuseIdentifier: Constants.CollectionViewCell.SHMessageShoutOutgoingCollectionViewCell)
        
//        if(self.title == nil)
//        {
//            if(self.model.conversation.users.count > 1 && self.model.conversation.users.count < 3)
//            {
//                if(![[self.model.conversation.users[0] username] isEqualToString:[[[SHLoginModel sharedModel]selfUser]username]])
//                {
//                    self.title = [self.model.conversation.users[0] name];
//                }else{
//                    self.title = [self.model.conversation.users[1] name];
//                }
//            }else
//            {
//                self.title = [NSString stringWithFormat:@"Chat with %d %@", (int)self.model.conversation.users.count,self.model.conversation.users.count==1?@"person":@"people"];
//            }
//            
//        }
        
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recievedMessage:", name: "kMessagePushNotification", object: nil)
        
//        self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:@"Helvetica" size:15.0f];
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
        viewModel?.viewDidAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.viewDidDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func recievedMessage (notification: NSNotification) {
        if let userInfo = notification.userInfo, let obj = userInfo["object"] {
            let conversation_id = obj["conversation_id"]
        }
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
//        if let navController = self.navigationController {
//            let navBar = self.navigationController?.navigationBar
//            if((self.progress == nil)) {
//                self.progress = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
//                self.progress?.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
//                self.progress?.backgroundColor = navBar?.window?.tintColor
//               // self.progress.progressTintColor = [UIColor jsq_messageBubbleBlueColor];
////                self.progress?.frame = CGRectMake(0, navBar?.frame.origin + navBar?.frame.size.height - 20, navBar?.frame.size.width, 2)
////                navBar?.addSubview(self.progress)
//            } else {
//                
//            }
//            self.progress?.setProgress(0, animated: false)
//        }
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.startProgress()
//        
//        SHMessage * msg = [[SHMessage alloc] init];
//        msg.user = self.myUser;
//        msg.text = text;
//        msg.created_at = [[NSDate date] timeIntervalSince1970];
//        
//        msg.isFromShout = self.isFromShout;
//        msg.status = kStatusPending;
        if(self.isFromShout) {
            
        }
//        if (self.isFromShout)
//        {
//            
//            [self.model composeMessage:text forShoutID:self.shoutID succsess:^(SHMessagesModel *model, SHMessage *message)
//                {
//                [self setStatus:kStatusSent forMessage:message];
//                [self finishProgress];
//                [JSQSystemSoundPlayer jsq_playMessageSentSound];
//                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Your message was sent successfully", @"Your message was sent successfully")];
//                
//                } failure:^(SHMessagesModel *model, NSError *error)
//                {
//                [self setStatus:kStatusFailed forMessage:msg];
//                [self finishProgress];
//                [self.model.faildToSendMessages addObject:msg];
//                [SHAlertView alertWithTitle:SH_MESSAGE_ERROR message:error.localizedDescription];
//                
//                }];
//            
//            [self.model.messages addObject:msg];
//            [self addMessageFrom:msg];
//            [self finishSendingMessage];
//            [self doneAction:nil];
//            
//        }
    }
    
    func startProgress () {
        self.progressTimer = NSTimer(timeInterval: 0.5, target: self, selector: Selector("increaseProgress:"), userInfo: nil, repeats: true)
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
    
    
    
    deinit {
        viewModel?.destroy()
    }
}
