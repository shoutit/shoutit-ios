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
import SwiftyJSON
import SVProgressHUD
import ObjectMapper

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
    
    // camera
    func cameraFinishWithImage (media: SHMedia, msg: SHMessage) {
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
//            //SHAmazonAWS uploadShoutImage:image progress:^(float percent)
//            let url = ""
//            if(self.viewController.isFromShout) {
//                if let shout = self.viewController.shout, let shoutId = shout.id {
//                    self.shApiMessage.composeImage(url, shoutID: shoutId, completionHandler: { (response) -> Void in
//                        self.viewController.finishProgress()
//                        switch(response.result) {
//                        case .Success( _):
//                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
//                            SHProgressHUD.show(NSLocalizedString("Your message was sent successfully", comment: "Your message was sent successfully"), maskType: .Black)
//                        case.Failure(let error):
//                            self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
//                            self.viewController.collectionView?.reloadData()
//                            self.viewController.finishProgress()
//                            JSQSystemSoundPlayer.jsq_playMessageSentAlert()
//                            self.failedToSendMessages.append(msg)
//                            log.error("Error composing Image \(error.localizedDescription)")
//                        }
//                        
//                    })
//                }
//            } else {
//                if let conversationId = self.viewController.conversationID {
//                    let localID = String(format: "%@-%d", arguments: [conversationId, Int(NSDate().timeIntervalSince1970)])
//                    msg.localId = localID
//                    self.shApiMessage.sendImage(url, conversationID: conversationId, localId: localID, completionHandler: { (response) -> Void in
//                        switch(response.result) {
//                        case .Success( _):
//                            self.viewController.setStatus(Constants.MessagesStatus.kStatusSent, msg: msg)
//                            self.viewController.collectionView?.reloadData()
//                            self.viewController.finishProgress()
//                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
//                        case .Failure(let error):
//                            self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
//                            self.viewController.collectionView?.reloadData()
//                            self.viewController.finishProgress()
//                            JSQSystemSoundPlayer.jsq_playMessageSentAlert()
//                            self.failedToSendMessages.append(msg)
//                            log.error("Error sending the message \(error.localizedDescription)")
//                        }
//                    })
//                    
//                }
//            }
//        }
        
        //-------------1812
//        self.viewController.resetProgress()
//        self.viewController.progressTimer?.invalidate()
//        self.viewController.progressTimer = nil
        if let conversationId = self.viewController.conversationID {
            let localID = String(format: "%@-%d", arguments: [conversationId, Int(NSDate().timeIntervalSince1970)])
            self.shApiMessage.sendImage(media, conversationID: conversationId, localId: localID, progress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                if let progressView = self.viewController.progress {
                    var p = progressView.progress
                    if(progressView.progress < 0.5) {
                        p += 0.1
                    } else if (progressView.progress < 0.8) {
                        p += 0.02
                    }
                    self.viewController.progress?.setProgress(p, animated: true)
                }
                }, completionHandler: { (response) -> Void in
                    switch(response.result) {
                    case .Success:
                        self.viewController.setStatus(Constants.MessagesStatus.kStatusSent, msg: msg)
                        self.viewController.finishProgress()
                        JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    case .Failure(let error):
                        self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                        self.viewController.collectionView?.reloadData()
                        self.viewController.finishProgress()
                        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
                        // self.failedToSendMessages.append(msg)
                        log.error("Error sending the message \(error.localizedDescription)")
                    }
            })
        }
        
        if(self.viewController.isFromShout) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.viewController.doneAction()
            })
        }
    }
    
    func cameraFinishWithVideoFile(media: SHMedia, msg: SHMessage) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            //SHAmazonAWS uploadVideo:tempVideoFileURL thumbImage:thumbImage progress:^(float progress)
//            let video = SHMedia()
//            if(self.viewController.isFromShout) {
//                if let shout = self.viewController.shout, let shoutId = shout.id {
//                    self.shApiMessage.composeVideo(video, shoutID: shoutId, completionHandler: { (response) -> Void in
//                        switch(response.result) {
//                        case .Success( _):
//                            self.viewController.finishProgress()
//                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
//                            SHProgressHUD.show(NSLocalizedString("Your message was sent successfully", comment: "Your message was sent successfully"), maskType: .Black)
//                        case .Failure(let error):
//                            self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
//                            self.viewController.collectionView?.reloadData()
//                            self.viewController.finishProgress()
//                            JSQSystemSoundPlayer.jsq_playMessageSentAlert()
//                            self.failedToSendMessages.append(msg)
//                            log.error("Error composing the video \(error.localizedDescription)")
//                        }
//                    })
//                }
//            } else {
//                if let conversationId = self.viewController.conversationID {
//                    let localID = String(format: "%@-%d", arguments: [conversationId, Int(NSDate().timeIntervalSince1970)])
//                    msg.localId = localID
//                    
//                }
//            }
        //----------1812
//            self.viewController.resetProgress()
//            self.viewController.progressTimer?.invalidate()
//            self.viewController.progressTimer = nil
            if let conversationId = self.viewController.conversationID {
                let localID = String(format: "%@-%d", arguments: [conversationId, Int(NSDate().timeIntervalSince1970)])
                self.shApiMessage.sendVideo(media, conversationID: conversationId, progress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                    if let progressView = self.viewController.progress {
                        var p = progressView.progress
                        if(progressView.progress < 0.5) {
                            p += 0.1
                        } else if (progressView.progress < 0.8) {
                            p += 0.02
                        }
                        self.viewController.progress?.setProgress(p, animated: true)
                    }
                    }, localId: localID, completionHandler: { (response) -> Void in
                        switch(response.result) {
                        case .Success:
                            self.viewController.setStatus(Constants.MessagesStatus.kStatusSent, msg: msg)
                            self.viewController.finishProgress()
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                        case .Failure(let error):
                            self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                            self.viewController.collectionView?.reloadData()
                            self.viewController.finishProgress()
                            JSQSystemSoundPlayer.jsq_playMessageSentAlert()
                            // self.failedToSendMessages.append(msg)
                            log.error("Error sending the message \(error.localizedDescription)")
                        }
                        
                })
            }
//        }
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
        SHProgressHUD.show(NSLocalizedString("Loading Chats...", comment: "Loading Chats..."), maskType: .Black)
        shApiMessage.loadMessagesForConversation(conversationId, beforeTimeStamp: 0, cacheResponse: { (shMessagesMeta) -> Void in
            self.viewController.updateMessages(shMessagesMeta)
            }) { (response) -> Void in
                SHProgressHUD.dismiss() 
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
                if let latitude = SHAddress.getUserOrDeviceLocation()?.latitude, let longitude = SHAddress.getUserOrDeviceLocation()?.longitude {
                    coord = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
                }
                self.viewController.startProgress()
                let msg = SHMessage()
                msg.user = self.viewController.myUser
                msg.text = ""
                msg.createdAt = Int(NSDate().timeIntervalSince1970)
                msg.isFromShout = self.viewController.isFromShout
                let locAttachment = SHLocationAttachment()
                
                locAttachment.location = SHAddress.getUserOrDeviceLocation()
                msg.attachments.append(locAttachment)
                
               // msg.attachments["location"] = coord as? AnyObject
                msg.status = Constants.MessagesStatus.kStatusPending
                
                if(self.viewController.isFromShout) {
                    if let shoutId = self.viewController.shout?.id {
                        self.shApiMessage.composeCoordinates(coord, shoutId: shoutId, completionHandler: { (response) -> Void in
                            switch(response.result) {
                            case .Success( _):
                                self.viewController.finishProgress()
                                JSQSystemSoundPlayer.jsq_playMessageSentSound()
//                                SHProgressHUD.show(NSLocalizedString("Your message was sent successfully", comment: "Your message was sent successfully"), maskType: .Black)
                                self.viewController.setStatus(Constants.MessagesStatus.kStatusSent, msg: msg)
                                self.shMessages.append(msg)
                                self.addMessageFrom(msg)
                               // self.viewController.finishSendingMessageAnimated(true)
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
                                self.viewController.finishProgress()
                                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                                self.shMessages.append(msg)
                                self.addMessageFrom(msg)
                                //self.viewController.finishSendingMessageAnimated(true)
                                self.viewController.finishSendingMessage()
                                
                            case .Failure(let error):
                                self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
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
                       // if let shMessage = response.result.value {
                            self.viewController.setStatus(Constants.MessagesStatus.kStatusSent, msg: msg)
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Your message was sent successfully", comment: "Your message was sent successfully"), maskType: .Black)
                       // }
                    } else if(response.result.isFailure) {
                        self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                        self.failedToSendMessages.append(msg)
                        // TODO
//                        [SHAlertView alertWithTitle:SH_MESSAGE_ERROR message:error.localizedDescription];
                        log.error("Error posting the message")
                    }
                })
                self.shMessages.append(msg)
                self.addMessageFrom(msg)
                //self.viewController.finishSendingMessageAnimated(true)
                self.viewController.finishSendingMessage()
                self.viewController.doneAction()
            }
        } else {
            if let conversationID = self.viewController.conversationID {
                let localID = String(format: "%@-%d", arguments: [conversationID, NSDate().timeIntervalSince1970 ])
                msg.localId = localID
                shApiMessage.sendMessage(text, conversationID: conversationID, localId: localID, completionHandler: { (response) -> Void in
                    self.viewController.finishProgress()
                    if(response.result.isSuccess) {
                       // if let shMessage = response.result.value {
                            self.viewController.setStatus(Constants.MessagesStatus.kStatusSent, msg: msg)
                            self.viewController.finishProgress()
                            self.viewController.finishReceivingMessage()
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                       // }
                    } else if(response.result.isFailure) {
                        self.viewController.setStatus(Constants.MessagesStatus.kStatusFailed, msg: msg)
                        self.viewController.collectionView?.reloadData()
                        self.viewController.finishProgress()
                        self.failedToSendMessages.append(msg)
                        // TODO
//                        [SHAlertView alertWithTitle:SH_MESSAGE_ERROR message:error.localizedDescription];
//                        log.error("Error sending the message")
                    }
                })
                self.shMessages.append(msg)
                self.addMessageFrom(msg)
                //self.viewController.finishSendingMessageAnimated(true)
                self.viewController.finishSendingMessage()
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
                let json = JSON(attachment)
                if json["images"].count > 0 {
                    if json["images"].count > 0 {
                        for (_, url) in json["images"] {
                            let media = SHImageMediaItem()
                            media.isOutgoing = (message.user?.username == self.viewController.myUser?.username)
                            if let user = message.user {
                                let shoutMessage = JSQMessage(senderId: user.username,
                                    displayName: user.name,
                                    media: media)
                                media.imageURL = url.stringValue
                                self.jsqMessages.append(shoutMessage)
                            }
                        }
                    }
//                    else {
//                        if let localImages = (attachment as? SHImageAttachment)?.localImages {
//                            for image in localImages {
//                                let media = SHImageMediaItem()
//                                media.isOutgoing = (message.user?.username == self.viewController.myUser?.username)
//                                if let user = message.user {
//                                    let shoutMessage = JSQMessage(senderId: user.username,
//                                        displayName: user.name,
//                                        media: media)
//                                    media.image = image.image
//                                    self.jsqMessages.append(shoutMessage)
//                                }
//                            }
//                        }
//                    }
                } else if json["videos"].count > 0 {
                    for (_, videoJSON) in json["videos"] {
                        let media = SHVideoMediaItem()
                        media.isOutgoing = (message.user?.username == self.viewController.myUser?.username)
                        if let user = message.user {
                            let video = SHMedia()
                            video.duration = videoJSON["duration"].intValue
                            video.thumbnailUrl = videoJSON["thumbnail_url"].stringValue
                            video.provider = videoJSON["provider"].stringValue
                            video.idOnProvider = videoJSON["id_on_provider"].stringValue
                            video.url = videoJSON["url"].stringValue
                            media.video = video
                            let shoutMessage = JSQMessage(senderId: user.username,
                                displayName: user.name,
                                media: media)
                            self.jsqMessages.append(shoutMessage)
                        }
                    }
                } else if json["shout"].count > 0 {
                   // for (_, shout) in json["shout"]{
                    let mediaItem = SHShoutMediaItem()
                    mediaItem.isOutgoing = (message.user?.username == self.viewController.myUser?.username)
                    let newShout = SHShout()
                    newShout.apiUrl = json["shout"]["api_url"].stringValue
                    newShout.currency = json["shout"]["currency"].stringValue
                    newShout.price = Double((round(json["shout"]["price"].doubleValue) * 100)/100)
                   // newShout.price = json["shout"]["price"].doubleValue
                    newShout.text = json["shout"]["text"].stringValue
                    newShout.thumbnail = json["shout"]["thumbnail"].stringValue
                    newShout.title = json["shout"]["title"].stringValue
                    newShout.videoUrl = json["shout"]["videoUrl"].stringValue
                    newShout.id = json["shout"]["id"].stringValue
                    mediaItem.shout = newShout
                    let shoutMessage = JSQMessage(senderId: message.user?.username,
                        displayName: message.user?.name,
                        media: mediaItem)
                    self.jsqMessages.append(shoutMessage)
                   // }
                } else if json["location"].count > 0 {
                    let longitude = json["location"]["longitude"].floatValue
                    let latitude = json["location"]["latitude"].floatValue
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
                }
                
                
//                    else if(location.latitude == 0 && location.longitude == 0) {
//                            if(message.text.isEmpty) {
//                                let media = SHLocationMediaItem()
//                                if let location = SHLocationAttachment().location, let longitude = location.longitude, let latitude = location.latitude {
//                                    
//                                    media.setLocation(CLLocation(latitude: Double(latitude), longitude: Double(longitude)), withCompletionHandler: { () -> Void in
//                                        self.viewController.collectionView?.reloadData()
//                                    })
//                                }
//                                
//                                if let user = message.user {
//                                    let locationMessage = JSQMessage(senderId: user.username,
//                                        displayName: user.name,
//                                        media: media)
//                                    self.jsqMessages.append(locationMessage)
//                                }
//                            }
//                        }
                
                 else if(attachment.isKindOfClass(SHImageAttachment)) {
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
                    }
                } else if(attachment.isKindOfClass(SHVideoAttachment)) {
                    let videos = (attachment as! SHVideoAttachment).videos
                    for video in videos {
                        let media = SHVideoMediaItem()
                        media.video = video
                        media.isOutgoing = (message.user?.username == self.viewController.myUser?.username)
                        if let user = message.user {
                            let shoutMessage = JSQMessage(senderId: user.username,
                                displayName: user.name,
                                media: media)
                            self.jsqMessages.append(shoutMessage)
                        }
                    }
                } else if(attachment.isKindOfClass(SHShoutAttachment)) {
                    if let shout = (attachment as! SHShoutAttachment).shout {
                        let media = SHShoutMediaItem()
                        media.shout = shout
                        media.isOutgoing = (message.user?.username == self.viewController.myUser?.username)
                        if let user = message.user {
                            let shoutMessage = JSQMessage(senderId: user.username,
                                displayName: user.name,
                                media: media)
                            self.jsqMessages.append(shoutMessage)
                        }
                    }
                } else if(attachment.isKindOfClass(SHLocationAttachment)) {
                    if let location = (attachment as! SHLocationAttachment).location, let longitude = location.longitude, let latitude = location.latitude {
                        let media = SHLocationMediaItem(maskAsOutgoing: message.user?.username == self.viewController.myUser?.username)
                        media.setLocation(CLLocation(latitude: Double(latitude), longitude: Double(longitude)), withCompletionHandler: { () -> Void in
                            self.viewController.collectionView?.reloadData()
                        })
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
