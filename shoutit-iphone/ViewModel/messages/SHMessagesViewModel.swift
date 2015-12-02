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

class SHMessagesViewModel: NSObject, JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout {

    private let viewController: SHMessagesViewController
    private var messages = [JSQMessage]()
    private var shMessages = [SHMessage]()
    private let shApiShout = SHApiShoutService()
    
    required init(viewController: SHMessagesViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        
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
    
    func sendButtonAction (text: String) {
        self.viewController.startProgress()
        let msg = SHMessage()
        msg.user = self.viewController.myUser
        msg.text = text
        msg.createdAt = Int(NSDate().timeIntervalSince1970)
        msg.isFromShout = self.viewController.isFromShout
        msg.status = "kStatusPending"
        
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
                        log.error("Error posting the message")
                    }
                })
            }
        } else {
            if let conversationID = self.viewController.conversationID {
                let localID = String(format: "%@-%d", arguments: [conversationID, NSDate().timeIntervalSince1970 ])
                msg.localId = localID
            }
            
        }
    }
    
    func addMessageFrom(message: SHMessage) {
        if(message.user == nil) {
            let mediaItem = SHSystemMessageMediaItem()
            if let createdAt = message.createdAt {
                mediaItem.prepareView(String(format: "%@ %@ ago", arguments: [message.text, NSDate(timeIntervalSince1970: Double(createdAt)).timeAgoSimple]))
                let msg = JSQMessage(senderId: self.viewController.senderId, senderDisplayName: self.viewController.senderDisplayName, date: NSDate(timeIntervalSince1970: Double(createdAt)), media: mediaItem)
                self.messages.append(msg)
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
    
    func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = self.messages[indexPath.item]
        if let messageSenderId = message.senderId {
            if messageSenderId == self.senderId() {
                return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN))
            }
        }
        
        return bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let msg = self.shMessages[indexPath.item]
        if(msg.user == nil) {
            return nil
        }
        let username = msg.user?.username
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
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(self.messages[indexPath.item].date)
        }
        return nil
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        if(message.senderId == self.senderId()) {
            return nil
        }
        if(indexPath.item - 1 > 0) {
            let previousMessage = self.messages[indexPath.item - 1]
            if let previousSenderId = previousMessage.senderId {
                if previousSenderId == message.senderId {
                    return nil
                }
            }
        }
        return NSAttributedString(string: "\(message.senderDisplayName)")
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let msg = self.shMessages[indexPath.item]
        if(msg.status == Constants.MessagesStatus.kStatusDelivered) {
            return NSAttributedString(string: NSLocalizedString("Delivered", comment: "Delivered"))
        }
        if(msg.status == Constants.MessagesStatus.kStatusSent) {
            return NSAttributedString(string: NSLocalizedString("Sent", comment: "Sent"))
        }
        if(msg.status == Constants.MessagesStatus.kStatusPending) {
            return NSAttributedString(string: NSLocalizedString("Pending", comment: "Pending"))
        }
        if(msg.status == Constants.MessagesStatus.kStatusFailed) {
            return NSAttributedString(string: NSLocalizedString("Failed", comment: "Failed"))
        }
        return nil
    }
    
    // UICollectionView DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = JSQMessagesCollectionViewCell()
        let msg = self.messages[indexPath.item]
        if((msg.isMediaMessage)) {
            if let textView = cell.textView, let textColor = cell.textView?.textColor {
                if(msg.senderId == self.senderId()) {
                    textView.textColor = UIColor.whiteColor()
                } else {
                    textView.textColor = UIColor.blackColor()
                }
                textView.linkTextAttributes = [NSForegroundColorAttributeName : textColor, NSUnderlineStyleAttributeName : (NSUnderlineStyle.StyleSingle as? AnyObject)!]
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
        
        let currentMessage = self.messages[indexPath.item]
        if(currentMessage.senderId == self.senderId()) {
            return 0.0
        }
        if(indexPath.item - 1 > 0) {
            let previousMessage = self.messages[indexPath.item - 1]
            if(previousMessage.senderId == currentMessage.senderId) {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 15.0
    }
    
    
    // Private 
    private func finishProgress () {
        if let timer = self.viewController.progressTimer {
            timer.invalidate()
            self.viewController.progress?.setProgress(1, animated: true)
            self.performSelector(Selector("resetProgress"), withObject: nil, afterDelay: 1)
        }
    }
    
    private func resetProgress () {
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
    
    
    
}
