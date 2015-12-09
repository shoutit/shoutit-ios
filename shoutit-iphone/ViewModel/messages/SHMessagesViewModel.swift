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

class SHMessagesViewModel: NSObject {

    private let viewController: SHMessagesViewController
    var jsqMessages = [JSQMessage]()
    var shMessages = [SHMessage]()
    var failedToSendMessages = [SHMessage]()
    let shApiShout = SHApiShoutService()
    let shApiMessage = SHApiMessageService()
    
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
            self.viewController.updateMessages(shMessagesMeta)
            }) { (response) -> Void in
                switch (response.result) {
                case .Success(let result):
                    self.viewController.updateMessages(result)
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
            SHCameraViewController.presentFromViewController(self.viewController, onlyPhoto: false, timeToRecord: 60, isVideoCV: false, firstVideo: true, delegate: viewController)
        case 2:
            let picker = UIStoryboard.getMessages().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHSHOUTPICKERTABLE) as! SHShoutPickerTableViewController
            self.viewController.hidesBottomBarWhenPushed = true
            picker.delegate = viewController
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
                                self.viewController.finishProgress()
                                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                                SHProgressHUD.show(NSLocalizedString("Your message was sent successfully", comment: "Your message was sent successfully"), maskType: .Black)
                                self.shMessages.append(msg)
                                self.addMessageFrom(msg)
                                self.viewController.finishSendingMessage()
                                self.viewController.doneAction()
                                
                            case .Failure(let error):
                                self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                                self.viewController.collectionView?.reloadData()
                                self.viewController.finishProgress()
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
                                self.viewController.setStatus(Constants.MessagesStatus.kStatusSent, msg: msg)
                                self.viewController.collectionView?.reloadData()
                                self.viewController.finishProgress()
                                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                                self.shMessages.append(msg)
                                self.addMessageFrom(msg)
                                self.viewController.finishSendingMessage()
                                
                            case .Failure(let error):
                                self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                                self.viewController.collectionView?.reloadData()
                                self.viewController.finishProgress()
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
                    self.viewController.finishProgress()
                    if(response.result.isSuccess) {
                        if let shMessage = response.result.value {
                            self.viewController.setStatus(Constants.MessagesStatus.kStatusSent, msg: shMessage)
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.shMessages.append(shMessage)
                            self.addMessageFrom(shMessage)
                            self.viewController.finishSendingMessage()
                            self.viewController.doneAction()
                        }
                    } else if(response.result.isFailure) {
                        self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
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
                    self.viewController.finishProgress()
                    if(response.result.isSuccess) {
                        if let shMessage = response.result.value {
                            self.viewController.setStatus(Constants.MessagesStatus.kStatusSent, msg: shMessage)
                            self.viewController.finishReceivingMessage()
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.shMessages.append(shMessage)
                            self.addMessageFrom(msg)
                            self.viewController.finishSendingMessage()
                        }
                    } else if(response.result.isFailure) {
                        self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
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
    
    // MARK - Private
    private func hidingTypingIndicatorAction () {
        self.viewController.showTypingIndicator = false
        self.viewController.collectionView?.reloadData()
        if(self.viewController.automaticallyScrollsToMostRecentMessage) {
            self.viewController.scrollToBottomAnimated(true)
        }
    }
        
}
