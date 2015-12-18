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
import SDWebImage
import MWPhotoBrowser
import AVKit

class SHMessagesViewController: JSQMessagesViewController, UIActionSheetDelegate, SHCameraViewControllerDelegate, SHShoutPickerTableViewControllerDelegate, AVPlayerViewControllerDelegate {
    
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
    var conversationManager: SHConversationPusherManager?
    var subTitleLabel: UILabel?
    private var media: [SHMedia] = []
    private var viewModel: SHMessagesViewModel?
    private var progressView: UIProgressView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewModel()
        self.mediaVideoController = URBMediaFocusViewController()
        self.typingCounter = 0
        self.conversationManager = SHConversationPusherManager()
        self.conversationManager?.conversationID = self.conversationID
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleCollectionTapRecognizer:"))
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
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
        self.collectionView?.collectionViewLayout.springinessEnabled = false
        viewModel?.viewDidAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupProgressBar()
        if(!self.isFromShout) {
            self.viewModel?.setupConverstaionManager()
//            [self setupConverstaionManager];
//            [self startCheckingStatus];
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("deleteMessage:"), name: "DeleteMessageNotification", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textDidChange"), name: UITextViewTextDidChangeNotification, object: nil)
        }
        viewModel?.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.inputToolbar?.contentView?.textView?.resignFirstResponder()
        self.progress?.removeFromSuperview()
        if(!self.isFromShout) {
            self.conversationManager?.unbindAll()
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
            if let timer = self.typingTimer {
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
            if let user = self.myUser {
                self.conversationManager?.sendTyping(user)
            }
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
        
        subTitleLabel = UILabel(frame: CGRectMake(0, 22, 0, 0))
        subTitleLabel?.textAlignment = NSTextAlignment.Center
        subTitleLabel?.backgroundColor = UIColor.clearColor()
        subTitleLabel?.textColor = UIColor.whiteColor()
        subTitleLabel?.font = UIFont.systemFontOfSize(12)
        //[self checkStaus];
        subTitleLabel?.text = "offline"
        subTitleLabel?.sizeToFit()
        
        let twoLineTitleView = UIView(frame: CGRectMake(0, 0, max(subTitleLabel!.frame.size.width, titleLabel.frame.size.width), 30))
        twoLineTitleView.addSubview(titleLabel)
        twoLineTitleView.addSubview(subTitleLabel!)
        
        let widthDiff = subTitleLabel!.frame.size.width - titleLabel.frame.size.width
        if(widthDiff > 0) {
            var frame = titleLabel.frame
            frame.origin.x = widthDiff / 2
            titleLabel.frame = CGRectIntegral(frame)
        } else {
            var frame = subTitleLabel!.frame
            frame.origin.x = abs(widthDiff) / 2
            subTitleLabel?.frame = CGRectIntegral(frame)
        }
        self.navigationItem.titleView = twoLineTitleView
    }
    
    func setupProgressBar() {
        if let navBar = self.navigationController?.navigationBar {
            if self.progress == nil {
                self.progress = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
                self.progress?.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
                self.progress?.backgroundColor = navBar.window?.tintColor
                self.progress?.progressTintColor = UIColor.jsq_messageBubbleBlueColor()
                self.progress?.frame = CGRectMake(0, navBar.frame.origin.y + navBar.frame.size.height, navBar.frame.size.width, 2)
                if let progress = self.progress {
                    navBar.addSubview(progress)
                }
            }
        }
        self.progress?.setProgress(0, animated: false)
    }
    
    func startProgress () {
        self.progressTimer = NSTimer(timeInterval: 0.5, target: self, selector: Selector("increaseProgress:"), userInfo: nil, repeats: true)
    }
    
    func resetProgress () {
        self.progress?.setProgress(0, animated: false)
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
        self.statusCheckerTimer = NSTimer(timeInterval: 10, target: self, selector: Selector("checkStatus"), userInfo: nil, repeats: true)
    }
    
    func checkStatus () {
        let online = self.conversationManager?.whoIsOnline()
        log.verbose("Online Members \(online)")
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if(online > 1) {
                self.subTitleLabel?.text = NSLocalizedString("online", comment: "online")
            } else {
                self.subTitleLabel?.text = NSLocalizedString("offline", comment: "offline")
            }
            self.subTitleLabel?.sizeToFit()
        }
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
    
    // JSQMessagesViewController
    
    // JSQMessagesCollectionViewDataSource
    
//    func senderDisplayName() -> String! {
//        if let user = self.myUser {
//            return user.name
//        }
//        return ""
//    }
//    
//    func senderId() -> String! {
//        if let user = self.myUser {
//            return user.username
//        }
//        return ""
//    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.viewModel?.jsqMessages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = self.viewModel?.jsqMessages[indexPath.item]
        if let messageSenderId = message?.senderId {
            if messageSenderId == self.senderId {
                return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN))
            }
        }
        return bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let imageView = UIImageView()
        if let imageUrl = self.myUser?.image where self.myUser?.name == self.viewModel?.jsqMessages[indexPath.item].senderDisplayName {
            imageView.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: UIImage(named: "no_image_available"))
        } else {
            imageView.image = UIImage(named: "profile")
        }
        let avImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(imageView.image, diameter: UInt( kJSQMessagesCollectionViewAvatarSizeDefault))
        return avImage;
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if(indexPath.item % 3 == 0) {
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(self.viewModel?.jsqMessages[indexPath.item].date)
        }
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.viewModel?.jsqMessages[indexPath.item]
        if(message?.senderId == self.senderId) {
            return nil
        }
        if(indexPath.item - 1 > 0) {
            let previousMessage = self.viewModel?.jsqMessages[indexPath.item - 1]
            if let previousSenderId = previousMessage?.senderId {
                if previousSenderId == message?.senderId {
                    return nil
                }
            }
        }
        return NSAttributedString(string: "\(self.senderDisplayName)")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if let msg = self.viewModel?.shMessages[indexPath.item] {
            if(msg.status == Constants.MessagesStatus.kStatusDelivered) {
                return NSAttributedString(string: Constants.MessagesStatus.kStatusDelivered)
            }
            if(msg.status == Constants.MessagesStatus.kStatusSent) {
                return NSAttributedString(string: Constants.MessagesStatus.kStatusSent)
            }
            if(msg.status == Constants.MessagesStatus.kStatusPending) {
                return NSAttributedString(string: Constants.MessagesStatus.kStatusPending)
            }
            if(msg.status == Constants.MessagesStatus.kStatusFailed) {
                return NSAttributedString(string: Constants.MessagesStatus.kStatusFailed)
            }
        }
        return nil
    }
    
    // UICollectionView DataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let messages = self.viewModel?.jsqMessages {
            return messages.count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        if let msg = self.viewModel?.jsqMessages[indexPath.item] where !msg.isMediaMessage {
            if let textView = cell.textView, let textColor = cell.textView?.textColor {
                if(msg.senderId == self.senderId) {
                    textView.textColor = UIColor.whiteColor()
                } else {
                    textView.textColor = UIColor.blackColor()
                }
                textView.linkTextAttributes = [
                    NSForegroundColorAttributeName: textColor,
                    NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue | NSUnderlineStyle.PatternSolid.rawValue
                ]
            }
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // mark - JSQMessages collection view flow layout delegate
    // mark - Adjusting cell label heights
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if(indexPath.item % 3 == 0) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let currentMessage = self.viewModel?.jsqMessages[indexPath.item]
        if let user = currentMessage?.senderId {
            if(user == self.senderId) {
                return 0.0
            }
            if(indexPath.item - 1 > 0) {
                let previousMessage = self.viewModel?.jsqMessages[indexPath.item - 1]
                if(previousMessage?.senderId == user) {
                    return 0.0
                }
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 15.0
    }
    
    // Responding to collection view tap events
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        if let conversationId = self.conversationID, let timeStamp = self.viewModel?.shMessages.first?.createdAt  {
            self.viewModel?.shApiMessage.loadMessagesForConversation(conversationId, beforeTimeStamp: timeStamp, cacheResponse: { (shMessagesMeta) -> Void in
                self.updateMessages(shMessagesMeta)
                }) { (response) -> Void in
                    switch (response.result) {
                    case .Success(let result):
                        self.updateMessages(result)
                    case .Failure(let error):
                        log.error("Error fetching messages \(error.localizedDescription)")
                    }
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        if let msg = self.viewModel?.shMessages[indexPath.item], let user = msg.user {
            let profileViewController = UIStoryboard.getProfile().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHPROFILE) as! SHProfileCollectionViewController
            profileViewController.requestUser(user)
            //self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        if let message = self.viewModel?.jsqMessages[indexPath.item] where message.isMediaMessage {
            if(message.media.isKindOfClass(SHShoutMediaItem)) {
                if let shout = (message.media as? SHShoutMediaItem)?.shout, let shoutId = shout.id {
                    let detailView = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHSHOUTDETAIL) as! SHShoutDetailTableViewController
                    detailView.title = shout.title
                    detailView.getShoutDetails(shoutId)
                    self.navigationController?.pushViewController(detailView, animated: true)
                }
            } else if(message.media.isKindOfClass(SHLocationMediaItem)) {
                if let location = (message.media as? SHLocationMediaItem)?.location {
                    let vc = UIStoryboard.getMessages().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHMAPDETAIL) as! SHMapDetatilViewController
                    let navController = UINavigationController(rootViewController: vc)
                    navController.navigationBar.barTintColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
                    navController.navigationBar.tintColor = UIColor.whiteColor()
                    self.presentViewController(navController, animated: true, completion: nil)
                    vc.location = location
                    vc.shout = shout
//                     SHMapDetatilViewController.presentFromViewController(self, location: location, shout: shout)
                }
            } else if(message.media.isKindOfClass(SHImageMediaItem)) {
                if let item = message.media as? SHImageMediaItem {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        var browser = MWPhotoBrowser(delegate: item)
                        browser.displayActionButton = false
                        browser.displayNavArrows = false
                        browser.displaySelectionButtons = false
                        browser.zoomPhotosToFill = true
                        browser.alwaysShowControls = false
                        browser.enableGrid = true
                        browser.startOnGrid = false
                        browser.navigationController?.navigationBar.tintColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
                        browser.navigationController?.navigationBar.opaque = false
                        let transition = CATransition()
                        transition.duration = 0.3
                        transition.type = kCATransitionFade
                        transition.subtype = kCATransitionFromTop
                        self.navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
                        self.navigationController?.pushViewController(browser, animated: true)
                        browser = nil
                    })
                }
                
            } else if(message.media.isKindOfClass(SHVideoMediaItem)) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let item = (message.media as?  SHVideoMediaItem) {
                        if let videoLocalUrl = item.video?.localUrl {
                            let player = AVPlayer(URL: videoLocalUrl)
                            let viewC = AVPlayerViewController()
                            viewC.player = player
                            viewC.player?.play()
                            self.navigationController?.presentViewController(viewC, animated: true, completion: nil)
                        } else if let videoUrl = item.video?.url, let url = NSURL(string: videoUrl) {
                            let player = AVPlayer(URL: url)
                            let viewC = AVPlayerViewController()
                            viewC.player = player
                            viewC.player?.play()
                            self.navigationController?.presentViewController(viewC, animated: true, completion: nil)
                            
                        } else {
                            SHProgressHUD.show(NSLocalizedString("Video is not available", comment: "Video is not available"), maskType: .Black)
                        }
                    }
                })
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        log.verbose("Tapped cell at %@!", functionName: NSStringFromCGPoint(touchLocation))
    }
    
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewCell
        if let _ = cell.mediaView {
            return action == Selector("delete:")
        } else {
            let test: Bool = action == Selector("delete:")
            return (test || action == Selector("copy:"))
        }
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewCell
        if let _ = cell.mediaView {
            
        } else if (action == Selector("copy:")) {
            super.collectionView(collectionView, performAction: action, forItemAtIndexPath: indexPath, withSender: sender)
        }
    }
    
    //SHShoutPickerTableViewControllerDelegate
    func didFinishSelect (shout: SHShout) {

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.startProgress()
            let msg = SHMessage()
            msg.user = self.myUser
            msg.text = ""
            msg.createdAt = Int(NSDate().timeIntervalSince1970)
            msg.isFromShout = self.isFromShout
            //msg.attachments.append(shout)
            msg.status = Constants.MessagesStatus.kStatusPending
            
            let shoutAttachment = SHShoutAttachment()
            shoutAttachment.shout = shout
            msg.attachments.append(shoutAttachment)
            msg.status = Constants.MessagesStatus.kStatusPending
            
            if(self.isFromShout) {
                if let shout = self.shout, let id = shout.id {
                    self.viewModel?.shApiMessage.composeShout(shout, shoutId: id, completionHandler: { (response) -> Void in
                        self.finishProgress()
                        if(response.result.isSuccess) {
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            SHProgressHUD.show(NSLocalizedString("Your message was sent successfully", comment: "Your message was sent successfully"), maskType: .Black)
                            self.setStatus(Constants.MessagesStatus.kStatusSent, msg: msg)
                        } else if(response.result.isFailure) {
                            self.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                            self.collectionView?.reloadData()
                            JSQSystemSoundPlayer.jsq_playMessageSentAlert()
                            self.viewModel?.failedToSendMessages.append(msg)
                            log.error("Error composing the shout message")
                        }
                        self.viewModel?.shMessages.append(msg)
                        self.viewModel?.addMessageFrom(msg)
                        self.finishSendingMessageAnimated(true)
                       // self.finishSendingMessage()
                        self.doneAction()
                    })
                }
            } else {
                if let conversationId = self.conversationID {
                    let localID = String(format: "%@-%d", arguments: [conversationId, NSDate().timeIntervalSince1970])
                    msg.localId = localID
                    self.viewModel?.shApiMessage.sendShout(shout, conversationId: conversationId, localId: localID, completionHandler: { (response) -> Void in
                        switch(response.result) {
                        case .Success( _):
                            self.setStatus(Constants.MessagesStatus.kStatusSent, msg: msg)
                            self.collectionView?.reloadData()
                            self.finishProgress()
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                        case .Failure(let error):
                            self.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                            self.collectionView?.reloadData()
                            self.finishProgress()
                            JSQSystemSoundPlayer.jsq_playMessageSentAlert()
                            self.viewModel?.failedToSendMessages.append(msg)
                            log.error("Error sending shout: \(error.localizedDescription)")
                        }
                    })
                    self.viewModel?.shMessages.append(msg)
                    self.viewModel?.addMessageFrom(msg)
                   // self.finishSendingMessage()
                    self.finishSendingMessageAnimated(true)
                }
            }
            
        }
    }
    
    // MARK - SHCameraViewControllerDelegate
    func didCameraFinish(image: UIImage) {
        self.startProgress()
        let msg = SHMessage()
        msg.user = self.myUser
        msg.text = ""
        msg.createdAt = Int(NSDate().timeIntervalSince1970)
        msg.isFromShout = self.isFromShout
        
        let media = SHMedia()
        media.isVideo = false
        media.image = image
        self.media.insert(media, atIndex: 0)
        let imageAttachment = SHImageAttachment()
        imageAttachment.localImages.append(media)
        msg.attachments.append(imageAttachment)
        msg.status = Constants.MessagesStatus.kStatusPending
        self.viewModel?.shMessages.append(msg)
        self.viewModel?.addMessageFrom(msg)
       // self.finishSendingMessage()
        self.finishSendingMessageAnimated(true)
        self.viewModel?.cameraFinishWithImage(media, msg: msg)
    }
    
    func didCameraFinish(tempVideoFileURL: NSURL, thumbnailImage: UIImage) {
        self.startProgress()
        let msg = SHMessage()
        msg.user = self.myUser
        msg.text = ""
        msg.createdAt = Int(NSDate().timeIntervalSince1970)
        msg.isFromShout = self.isFromShout

        let media = SHMedia()
        media.isVideo = true
        media.upload = true
        media.localUrl = tempVideoFileURL
        media.localThumbImage = thumbnailImage
        self.media.append(media)
        let videoAttachment = SHVideoAttachment()
        videoAttachment.videos.append(media)
        msg.attachments.append(videoAttachment)
        msg.status = Constants.MessagesStatus.kStatusPending
        self.viewModel?.shMessages.append(msg)
        self.viewModel?.addMessageFrom(msg)
       // self.finishSendingMessage()
        self.finishSendingMessageAnimated(true)
        self.viewModel?.cameraFinishWithVideoFile(media, msg: msg)
    }
    
    func updateMessages(shMessagesMeta: SHMessagesMeta) {
//        var scrollToEnd = false
//        if let count = self.viewModel?.shMessages.count where count == 0 {
//            scrollToEnd = true
//        }
        self.viewModel?.shMessages = shMessagesMeta.results
        self.viewModel?.jsqMessages.removeAll()
        if let messages = self.viewModel?.shMessages {
            for (_, shMessage) in messages.enumerate() {
                self.viewModel?.addMessageFrom(shMessage)
            }
            self.automaticallyScrollsToMostRecentMessage = true
        }
        self.collectionView?.reloadData()
        if(self.automaticallyScrollsToMostRecentMessage) {
            self.scrollToBottomAnimated(true)
        }
    }
    
    func setStatus(status: String, msg: SHMessage) {
        if let messages = self.viewModel?.shMessages {
            for (key, _) in messages.enumerate() {
                if let m = self.viewModel?.shMessages[key] where m.localId == msg.localId {
                    m.status = status
                }
            }
        }
    }

}
