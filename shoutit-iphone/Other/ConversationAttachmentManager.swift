//
//  ConversationAttachmentManager.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class ConversationAttachmentManager {
    let attachmentSelected : PublishSubject<MessageAttachment> = PublishSubject()
    let presentingSubject : PublishSubject<UIViewController?> = PublishSubject()
    
    func requestAttachmentWithType(type: MessageAttachmentType) {
        switch type {
        case .Image:
            requestImageAttachment()
        case .Video:
            requestVideoAttachment()
        case .Location:
            requestLocationAttachment()
        case .Shout:
            requestShoutAttachment()
        }
    }
    
    private func requestLocationAttachment() {
        guard let user = Account.sharedInstance.user else {
            fatalError("User shouldnt be able to create attachment without logging in")
        }
        
        guard let longitude = user.location.longitude, latitude = user.location.latitude else {
            let alert = UIAlertController(title: NSLocalizedString("Could not send your location right now.", comment: ""), message: NSLocalizedString("Please make sure that your location services are enabled for Shoutit.", comment: ""), preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
            
            self.presentingSubject.onNext(alert)
                
            return
            
        }
        
        let locationAttachment = MessageLocation(longitude: longitude, latitude: latitude)
        
        let attachment = MessageAttachment(shout: nil, location: locationAttachment, videos: nil, images: nil)
        
        showConfirmationControllerForAttachment(attachment)
        
    }
    
    private func requestImageAttachment() {
        
    }
    
    private func requestVideoAttachment() {
        
    }
    
    private func requestShoutAttachment() {
        
    }
    
    private func showConfirmationControllerForAttachment(attachment: MessageAttachment) {
        let alert = UIAlertController(title: NSLocalizedString("Confirmation", comment: ""), message: confirmationMessageForType(attachment.type()), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Send Attachment", comment: ""), style: .Default, handler: { (alertAction) in
            self.attachmentSelected.onNext(attachment)
        }))
        
        self.presentingSubject.onNext(alert)
        
    }
    
    private func confirmationMessageForType(type: MessageAttachmentType) -> String {
        switch type {
        case .Video:
            return NSLocalizedString("Do you want to send selected video?", comment: "")
        case .Shout:
            return NSLocalizedString("Do you want to send selected shout?", comment: "")
        case .Location:
            return NSLocalizedString("Do you want to send your location?", comment: "")
        case .Image:
            return NSLocalizedString("Do you want to send selected picture?", comment: "")
        }
    }
    
}