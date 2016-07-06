//
//  SendAsMessageProcessingTask.swift
//  shoutit
//
//  Created by Piotr Bernad on 06.07.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class SendAsMessageProcessingTask: MediaProcessingTask {
    
    private var sendingAttachment : MediaAttachment!
    private var sendingAttachments : [MediaAttachment]!
    
    override func runWithMedia(media : MediaAttachment) -> Void {
        isRunning = true
        
        sendingAttachment = media
        
        guard let _ = media.image else {
            self.errorWithMessage(NSLocalizedString("No image provided for sending.", comment: ""))
            return
        }
        
        self.presentingSubject?.onNext(confirmationController())
    }
    
    override func runWithMedias(medias: [MediaAttachment]) {
        isRunning = true
        
        sendingAttachments = medias
        
        
    }
    
    func confirmationController() -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Confirmation", comment: ""), message: NSLocalizedString("Do you want to send selected media?", comment: <#T##String#>), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (_) in
            self.finish(self.sendingAttachment)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Send Attachment", comment: ""), style: .Default, handler: { (_) in
            self.triggerSend()
        }))

        return alert
    }
    
    func confirmationController() -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Confirmation", comment: ""), message: NSLocalizedString("Do you want to send selected media?", comment: <#T##String#>), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (_) in
            self.finish(self.sendingAttachment)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Send Attachment", comment: ""), style: .Default, handler: { (_) in
            self.triggerSend()
        }))
        
        return alert
    }
    
    func triggerSend() {
        self.finish(self.sendingAttachment)
    }
}
