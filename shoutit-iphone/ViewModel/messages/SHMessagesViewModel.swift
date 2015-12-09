//
//  SHMessagesViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 30/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SDWebImage
import MWPhotoBrowser

class SHMessagesViewModel: NSObject, JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout, SHCameraViewControllerDelegate, SHShoutPickerTableViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    private let viewController: SHMessagesViewController
    private var jsqMessages = [JSQMessage]()
    private var shMessages = [SHMessage]()
    private var failedToSendMessages = [SHMessage]()
    private let shApiShout = SHApiShoutService()
    private let shApiMessage = SHApiMessageService()
    
    required init(viewController: SHMessagesViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if let conversationId =  self.viewController.conversationID {
            getMessagesById(conversationId)
        }
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    //SetUp ConversationPusherManager
    func setupConverstaionManager () {
        self.viewController.conversationManager?.subscribeToEventsWithMessageHandler({ (event) -> () in
            log.verbose("Message Handler \(event)")
            }, typingHandler: { (event) -> () in
                if let typingTimer = self.viewController.typingTimer {
                    typingTimer.invalidate()
                }
                self.viewController.typingTimer = NSTimer(timeInterval: 5, target: self, selector: Selector("hideTypingIndicator"), userInfo: nil, repeats: false)
                log.verbose("Typing... \(event["username"])")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.hidingTypingIndicatorAction()
                })
                
            }, joined_chatHandler: { (event) -> () in
                log.verbose("joined_chathandler \(event)")
            }, left_chatHandler: { (event) -> () in
                log.verbose("left_chathandler \(event)")
        })
    }
    
    func hideTypingIndicator () {
        if let typingTimer = self.viewController.typingTimer  {
            typingTimer.invalidate()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.hidingTypingIndicatorAction()
            })
        }
    }
    
    
    //TapTitleAction
    func tapTitleAction () {
//        SHShout* shout = self.model.conversation.aboutShout;
//        if(!shout) return;
//        SHShoutDetailTableViewController* detailView = [SHNavigator viewControllerFromStoryboard:@"StreamStoryboard" withViewControllerId:@"SHShoutDetailTableViewController"];
//        detailView.title = [shout title];
//        [detailView getDetailShouts:shout];
//        self.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:detailView animated:YES];
    }
    
    // Received Message
    func receivedMessage(notification: NSNotification) {
        if let userInfo = notification.userInfo, let obj = userInfo["object"] {
            let conversation_id = String(obj["conversation_id"])
            if let conversationId = self.viewController.conversationID where conversationId == conversation_id {
                for message in self.shMessages {
                    if(message.messageId == String(obj["message_id"])) {
                        return
                    }
                }
                if let msg = obj as? SHMessage {
                    self.shMessages.append(msg)
                    self.addMessageFrom(msg)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.viewController.finishReceivingMessage()
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    })
                }
            }
        } else {
            AudioServicesPlaySystemSound(1054)
        }
    }
    
    // Get Messages by conversation Id
    func getMessagesById (conversationId: String) {
        self.jsqMessages.removeAll()
        shApiMessage.loadMessagesForConversation(conversationId, beforeTimeStamp: 0, cacheResponse: { (shMessagesMeta) -> Void in
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
    
    // Action Sheet
    func actionWithButtonIndex(actionSheet: UIActionSheet, buttonIndex: Int) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return
        }
        switch(buttonIndex) {
        case 1:
            SHCameraViewController.presentFromViewController(self.viewController, onlyPhoto: false, timeToRecord: 60, isVideoCV: false, firstVideo: true, delegate: self)
        case 2:
            let picker = UIStoryboard.getMessages().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHSHOUTPICKERTABLE) as! SHShoutPickerTableViewController
            self.viewController.hidesBottomBarWhenPushed = true
            picker.delegate = self
            self.viewController.navigationController?.pushViewController(picker, animated: true)
        case 3:
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                var coord = CLLocationCoordinate2D()
                if let latitude = SHAddress.getFromCache()?.latitude, let longitude = SHAddress.getFromCache()?.longitude {
                    coord = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
                }
                self.viewController.startProgress()
                let msg = SHMessage()
                msg.user = self.viewController.myUser
                msg.text = ""
                msg.createdAt = Int(NSDate().timeIntervalSince1970)
                msg.isFromShout = self.viewController.isFromShout
               // msg.attachments["location"] = coord as? AnyObject
                msg.status = Constants.MessagesStatus.kStatusPending
                
                if(self.viewController.isFromShout) {
                    if let shoutId = self.viewController.shout?.id {
                        self.shApiMessage.composeCoordinates(coord, shoutId: shoutId, completionHandler: { (response) -> Void in
                            switch(response.result) {
                            case .Success( _):
                                self.finishProgress()
                                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                                SHProgressHUD.show(NSLocalizedString("Your message was sent successfully", comment: "Your message was sent successfully"), maskType: .Black)
                                self.shMessages.append(msg)
                                self.addMessageFrom(msg)
                                self.viewController.finishSendingMessage()
                                self.viewController.doneAction()
                                
                            case .Failure(let error):
                                self.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                                self.viewController.collectionView?.reloadData()
                                self.finishProgress()
                                JSQSystemSoundPlayer.jsq_playMessageSentAlert()
                                log.error("Error sending the location \(error.localizedDescription)")
                            }
                        })
                    }
                } else {
                    if let conversationId = self.viewController.conversationID {
                        let localID = String(format: "%@-%d", arguments: [conversationId, Int(NSDate().timeIntervalSince1970)])
                        msg.localId = localID
                        self.shApiMessage.sendCoordinates(coord, conversationID: conversationId, localId: localID, completionHandler: { (response) -> Void in
                            switch(response.result) {
                            case .Success( _):
                                self.setStatus(Constants.MessagesStatus.kStatusSent, msg: msg)
                                self.viewController.collectionView?.reloadData()
                                self.finishProgress()
                                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                                self.shMessages.append(msg)
                                self.addMessageFrom(msg)
                                self.viewController.finishSendingMessage()
                                
                            case .Failure(let error):
                                self.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                                self.viewController.collectionView?.reloadData()
                                self.finishProgress()
                                JSQSystemSoundPlayer.jsq_playMessageSentAlert()
                                log.error("Error sending the coordinates \(error.localizedDescription)")
                            }
                        })
                    }
                }
            })
        default:
            break
        }
    }
    //SHShoutPickerTableViewControllerDelegate
    func didFinishSelect (shout: SHShout) {
        // Check Code Duplication
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.viewController.startProgress()
            let msg = SHMessage()
            msg.user = self.viewController.myUser
            msg.text = ""
            msg.createdAt = Int(NSDate().timeIntervalSince1970)
            msg.isFromShout = self.viewController.isFromShout
            if let shout = self.viewController.shout {
              //  msg.attachments["shout"] = shout
            }
            msg.status = Constants.MessagesStatus.kStatusPending
            
            if(self.viewController.isFromShout) {
                if let shout = self.viewController.shout, let id = shout.id {
                    self.shApiMessage.composeShout(shout, shoutId: id, completionHandler: { (response) -> Void in
                        self.finishProgress()
                        if(response.result.isSuccess) {
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            SHProgressHUD.show(NSLocalizedString("Your message was sent successfully", comment: "Your message was sent successfully"), maskType: .Black)
                            self.shMessages.append(msg)
                            self.addMessageFrom(msg)
                            self.viewController.finishSendingMessage()
                            self.viewController.doneAction()
                        } else if(response.result.isFailure) {
                            self.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                            self.viewController.collectionView?.reloadData()
                            JSQSystemSoundPlayer.jsq_playMessageSentAlert()
                            self.failedToSendMessages.append(msg)
                            log.error("Error composing the shout message")
                        }
                    })
                }
            } else {
                if let conversationId = self.viewController.conversationID {
                    let localID = String(format: "%@-%d", arguments: [conversationId, NSDate().timeIntervalSince1970])
                    msg.localId = localID
                    self.shApiMessage.sendShout(shout, conversationId: conversationId, localId: localID, completionHandler: { (response) -> Void in
                        switch(response.result) {
                        case .Success( _):
                            self.setStatus(Constants.MessagesStatus.kStatusSent, msg: msg)
                            self.viewController.collectionView?.reloadData()
                            self.viewController.finishProgress()
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.shMessages.append(msg)
                            self.addMessageFrom(msg)
                            self.viewController.finishSendingMessage()
                        case .Failure(let error):
                            self.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                            self.viewController.collectionView?.reloadData()
                            self.viewController.finishProgress()
                            JSQSystemSoundPlayer.jsq_playMessageSentAlert()
                            self.failedToSendMessages.append(msg)
                            log.error("Error sending shout: \(error.localizedDescription)")
                        }
                    })
                }
            }
            
        }
    }
    
    // MARK - SHCameraViewControllerDelegate
    func didCameraFinish(image: UIImage) {
        let media = SHMedia()
        media.isVideo = false
        media.image = image
        self.viewController.collectionView?.reloadData()
    }
    
    func didCameraFinish(tempVideoFileURL: NSURL, thumbnailImage: UIImage) {
        let media = SHMedia()
        media.isVideo = true
        media.upload = true
        media.localUrl = tempVideoFileURL
        media.localThumbImage = thumbnailImage
        self.viewController.collectionView?.reloadData()
    }

    func sendButtonAction (text: String) {
        self.viewController.startProgress()
        let msg = SHMessage()
        msg.user = self.viewController.myUser
        msg.text = text
        msg.createdAt = Int(NSDate().timeIntervalSince1970)
        msg.isFromShout = self.viewController.isFromShout
        msg.status = Constants.MessagesStatus.kStatusPending
        
        if(self.viewController.isFromShout) {
            if let shoutId = self.viewController.shout?.id {
                shApiShout.composeMessage(text, shoutId: shoutId, completionHandler: { (response) -> Void in
                    self.finishProgress()
                    if(response.result.isSuccess) {
                        if let shMessage = response.result.value {
                            self.setStatus(Constants.MessagesStatus.kStatusSent, msg: shMessage)
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.shMessages.append(shMessage)
                            self.addMessageFrom(shMessage)
                            self.viewController.finishSendingMessage()
                            self.viewController.doneAction()
                        }
                    } else if(response.result.isFailure) {
                        self.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                        self.failedToSendMessages.append(msg)
                        log.error("Error posting the message")
                    }
                })
            }
        } else {
            if let conversationID = self.viewController.conversationID {
                let localID = String(format: "%@-%d", arguments: [conversationID, NSDate().timeIntervalSince1970 ])
                msg.localId = localID
                shApiMessage.sendMessage(text, conversationID: conversationID, localId: localID, completionHandler: { (response) -> Void in
                    self.finishProgress()
                    if(response.result.isSuccess) {
                        if let shMessage = response.result.value {
                            self.setStatus(Constants.MessagesStatus.kStatusSent, msg: shMessage)
                            self.viewController.finishReceivingMessage()
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.shMessages.append(shMessage)
                            self.addMessageFrom(msg)
                            self.viewController.finishSendingMessage()
                        }
                    } else if(response.result.isFailure) {
                        self.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                        self.viewController.collectionView?.reloadData()
                        self.failedToSendMessages.append(msg)
                        log.error("Error sending the message")
                    }
                })
                
            }
            
        }
    }
    
    func addMessageFrom(message: SHMessage) {
        if(message.user == nil) {
            let mediaItem = SHSystemMessageMediaItem()
            if let createdAt = message.createdAt {
                mediaItem.prepareView(String(format: "%@ %@ ago", arguments: [message.text, NSDate(timeIntervalSince1970: Double(createdAt)).timeAgoSimple]))
                
                let msg = JSQMessage(senderId: self.viewController.senderId,
                    senderDisplayName: self.viewController.senderDisplayName,
                    date: NSDate(timeIntervalSince1970: Double(createdAt)),
                    media: mediaItem)
                
                self.jsqMessages.append(msg)
            }
        } else if (message.attachments.count > 0) {
            for attachment in message.attachments {
                if(attachment.isKindOfClass(SHShoutAttachment)) {
                    if let shout = SHShoutAttachment().shout {
                        let mediaItem = SHShoutMediaItem()
                        mediaItem.shout = shout
                        mediaItem.isOutgoing = (message.user?.username == self.viewController.myUser?.username)
                        
                        let shoutMessage = JSQMessage(senderId: message.user?.username,
                            displayName: message.user?.name,
                            media: mediaItem)
                        
                        self.jsqMessages.append(shoutMessage)
                    }
                } else if(attachment.isKindOfClass(SHLocationAttachment)) {
                    if let location = SHLocationAttachment().location, let longitude = location.longitude, let latitude = location.latitude {
                        if(location.latitude != 0 && location.latitude != 0) {
                            
                            let media = SHLocationMediaItem()
                            media.setLocation(CLLocation(latitude: Double(latitude), longitude: Double(longitude)), withCompletionHandler: { () -> Void in
                                self.viewController.collectionView?.reloadData()
                            })
                            
                            if let user = message.user {
                                let locationMessage = JSQMessage(senderId: user.username,
                                    displayName: user.name,
                                    media: media)
                                self.jsqMessages.append(locationMessage)
                            }
                        } else if(location.latitude == 0 && location.longitude == 0) {
                            if(message.text.isEmpty) {
                                let media = SHLocationMediaItem()
                                if let location = SHLocationAttachment().location, let longitude = location.longitude, let latitude = location.latitude {
                                    
                                    media.setLocation(CLLocation(latitude: Double(latitude), longitude: Double(longitude)), withCompletionHandler: { () -> Void in
                                        self.viewController.collectionView?.reloadData()
                                    })
                                }
                                
                                if let user = message.user {
                                    let locationMessage = JSQMessage(senderId: user.username,
                                        displayName: user.name,
                                        media: media)
                                    self.jsqMessages.append(locationMessage)
                                }
                            }
                        }
                    }
                } else if(attachment.isKindOfClass(SHImageAttachment)) {
                    if let localImages = (attachment as? SHImageAttachment)?.localImages {
                        for image in localImages {
                            let media = SHImageMediaItem()
                            media.isOutgoing = (message.user?.username == self.viewController.myUser?.username)
                            if let user = message.user {
                                let shoutMessage = JSQMessage(senderId: user.username,
                                    displayName: user.name,
                                    media: media)
                                media.image = image.image
                                self.jsqMessages.append(shoutMessage)
                            }
                        }
                    } else if let images = (attachment as? SHImageAttachment)?.images {
                        for imageUrl in images {
                            let media = SHImageMediaItem()
                            media.isOutgoing = (message.user?.username == self.viewController.myUser?.username)
                            if let user = message.user {
                                let shoutMessage = JSQMessage(senderId: user.username,
                                    displayName: user.name,
                                    media: media)
                                media.imageURL = imageUrl.url
                                self.jsqMessages.append(shoutMessage)
                            }
                        }
                    }
                } else if(attachment.isKindOfClass(SHVideoAttachment)) {
                    let videos = (attachment as! SHVideoAttachment).videos
                    for video in videos {
                        let media = SHVideoMediaItem()
                        media.video = video
                        //[media setIsOutgoing:[message.user.username isEqualToString:self.myUser.username]];
                        if let user = message.user {
                            let shoutMessage = JSQMessage(senderId: user.username,
                                displayName: user.name,
                                media: media)
                            self.jsqMessages.append(shoutMessage)
                        }
                    }
                }
            }
        } else {
            if let user = message.user, let createdAt = message.createdAt {
                let jmsg = JSQMessage(senderId: user.username, senderDisplayName: user.name, date: NSDate(timeIntervalSince1970: Double(createdAt)), text: message.text)
                self.jsqMessages.append(jmsg)
            }
        }
    }
    
    // JSQMessagesViewController
    
    // JSQMessagesCollectionViewDataSource
    
    func senderDisplayName() -> String! {
        if let user = self.viewController.myUser {
            return user.name
        }
        return ""
    }
  
    func senderId() -> String! {
        if let user = self.viewController.myUser {
            return user.username
        }
        return ""
    }
    
    func deleteMessage(aNotification: NSNotification) {
        let cell = aNotification.object as! JSQMessagesCollectionViewCell
        if let indexPath = self.viewController.collectionView?.indexPathForCell(cell) {
            shApiMessage.deleteMessageID(self.shMessages[indexPath.row].messageId) { (response) -> Void in
                if(response.result.isSuccess) {
                    log.verbose("Message deleted.")
                } else {
                    log.verbose("Message not deleted.")
                }
            }
            self.jsqMessages.removeAtIndex(indexPath.row)
            self.shMessages.removeAtIndex(indexPath.row)
            self.viewController.collectionView?.deleteItemsAtIndexPaths([indexPath])
        }
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.jsqMessages[indexPath.item]
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = self.jsqMessages[indexPath.item]
        if let messageSenderId = message.senderId {
            if messageSenderId == self.senderId() {
                return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN))
            }
        }
        return bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
//        let msg = self.shMessages[indexPath.item]
//        if(msg.user == nil) {
//            return nil
//        }
//        let username = msg.user?.username
        let username = self.jsqMessages[indexPath.item].senderDisplayName
       // let image = SDImageCache
        //UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:username];
        var image = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(username)
        if (image == nil) {
            image = UIImage(named: "no_image_available")
        }
        
        let avImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt( kJSQMessagesCollectionViewAvatarSizeDefault))
        return avImage;
       
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if(indexPath.item % 3 == 0) {
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(self.jsqMessages[indexPath.item].date)
        }
        return nil
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.jsqMessages[indexPath.item]
        if(message.senderId == self.senderId()) {
            return nil
        }
        if(indexPath.item - 1 > 0) {
            let previousMessage = self.jsqMessages[indexPath.item - 1]
            if let previousSenderId = previousMessage.senderId {
                if previousSenderId == message.senderId {
                    return nil
                }
            }
        }
        return NSAttributedString(string: "\(self.viewController.senderDisplayName)")
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
//        let msg = self.shMessages[indexPath.item]
//        if(msg.status == Constants.MessagesStatus.kStatusDelivered) {
//            return NSAttributedString(string: NSLocalizedString("Delivered", comment: "Delivered"))
//        }
//        if(msg.status == Constants.MessagesStatus.kStatusSent) {
//            return NSAttributedString(string: NSLocalizedString("Sent", comment: "Sent"))
//        }
//        if(msg.status == Constants.MessagesStatus.kStatusPending) {
//            return NSAttributedString(string: NSLocalizedString("Pending", comment: "Pending"))
//        }
//        if(msg.status == Constants.MessagesStatus.kStatusFailed) {
//            return NSAttributedString(string: NSLocalizedString("Failed", comment: "Failed"))
//        }
        return nil
    }
    
    // UICollectionView DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.jsqMessages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.viewController.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let msg = self.jsqMessages[indexPath.item]
        if(!(msg.isMediaMessage)) {
            if let textView = cell.textView, let textColor = cell.textView?.textColor {
                if(msg.senderId == self.senderId()) {
                    textView.textColor = UIColor.whiteColor()
                } else {
                    textView.textColor = UIColor.blackColor()
                }
                textView.linkTextAttributes = [NSForegroundColorAttributeName : textColor]
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // mark - JSQMessages collection view flow layout delegate
    // mark - Adjusting cell label heights
    func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if(indexPath.item % 3 == 0) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    

    
    func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let currentMessage = self.jsqMessages[indexPath.item]
        if let user = currentMessage.senderId {
            if(user == self.senderId()) {
                return 0.0
            }
            if(indexPath.item - 1 > 0) {
                let previousMessage = self.jsqMessages[indexPath.item - 1]
                if(previousMessage.senderId == user) {
                    return 0.0
                }
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 15.0
    }
    
    // Responding to collection view tap events
    func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        if let conversationId = self.viewController.conversationID, let timeStamp = self.shMessages.first?.createdAt  {
            shApiMessage.loadMessagesForConversation(conversationId, beforeTimeStamp: timeStamp, cacheResponse: { (shMessagesMeta) -> Void in
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
    
    func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        let msg = self.shMessages[indexPath.item]
        if let user = msg.user {
            let profileViewController = UIStoryboard.getProfile().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHPROFILE) as! SHProfileCollectionViewController
            profileViewController.requestUser(user)
            self.viewController.hidesBottomBarWhenPushed = true
            self.viewController.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        if(self.jsqMessages[indexPath.item].isMediaMessage) {
            if(self.jsqMessages[indexPath.item].media.isKindOfClass(SHShoutMediaItem)) {
                if let shout = (self.jsqMessages[indexPath.item].media as? SHShoutMediaItem)?.shout, let shoutId = shout.id {
                    let detailView = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHSHOUTDETAIL) as! SHShoutDetailTableViewController
                    detailView.title = shout.title
                    detailView.getShoutDetails(shoutId)
                    self.viewController.hidesBottomBarWhenPushed = true
                    self.viewController.navigationController?.pushViewController(detailView, animated: true)
                }
            } else if(self.jsqMessages[indexPath.item].media.isKindOfClass(SHLocationMediaItem)) {
                let location = (self.jsqMessages[indexPath.item].media as? SHLocationMediaItem)?.location
//                [SHMapDetatilViewController presentFromViewController:self withLocationCoordinates:location shout:self.shout];
            } else if(self.jsqMessages[indexPath.item].media.isKindOfClass(SHImageMediaItem)) {
                let item = self.jsqMessages[indexPath.item].media as? SHImageMediaItem
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var browser = MWPhotoBrowser()
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
                    self.viewController.navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
                    self.viewController.navigationController?.pushViewController(browser, animated: true)
                    browser = MWPhotoBrowser()
                })
                
            } else if(self.jsqMessages[indexPath.item].media.isKindOfClass(SHVideoMediaItem)) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let item = (self.jsqMessages[indexPath.item].media as!  SHVideoMediaItem)
                    if let videoUrl = item.video?.localUrl {
                        let player = AVPlayer(URL: videoUrl)
                        
                    } else {
                        SHProgressHUD.show(NSLocalizedString("Video is not available", comment: "Video is not available"), maskType: .Black)
                    }
                })
            }
        }

    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        log.verbose("Tapped cell at %@!", functionName: NSStringFromCGPoint(touchLocation))
    }
    
    func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewCell
        if let _ = cell.mediaView {
            return action == Selector("delete:")
        } else {
            let test: Bool = action == Selector("delete:")
            return (test || action == Selector("copy:"))
        }
    }
    
    func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewCell
        if let _ = cell.mediaView {
            
        } else if (action == Selector("copy:")) {
            self.collectionView(collectionView, performAction: action, forItemAtIndexPath: indexPath, withSender: sender)
        }
    }
    
    // Private 
    private func finishProgress () {
        if let timer = self.viewController.progressTimer {
            timer.invalidate()
            self.viewController.progress?.setProgress(1, animated: true)
            self.performSelector(Selector("resetProgress"), withObject: nil, afterDelay: 1)
        }
    }
    
    func resetProgress () {
        self.viewController.progress?.setProgress(0, animated: false)
    }
    
    private func setStatus(status: String, msg: SHMessage) {
        for (key, _) in self.shMessages.enumerate() {
            let m = self.shMessages[key]
            if(m.localId == msg.localId) {
                m.status = status
            }
        }
        
    }
    
    private func updateMessages(shMessagesMeta: SHMessagesMeta) {
        self.shMessages = shMessagesMeta.results
        for (_, shMessage) in self.shMessages.enumerate() {
            self.addMessageFrom(shMessage)
        }
        self.viewController.collectionView?.reloadData()
    }
    
    private func hidingTypingIndicatorAction () {
        self.viewController.showTypingIndicator = false
        self.viewController.collectionView?.reloadData()
        if(self.viewController.automaticallyScrollsToMostRecentMessage) {
            self.viewController.scrollToBottomAnimated(true)
        }
    }
    
}
