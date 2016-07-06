//
//  AviaryEditProcessingTask.swift
//  shoutit
//
//  Created by Piotr Bernad on 06.07.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation


class AviaryEditProcessingTask: MediaProcessingTask {
    
    private var editingController : AdobeUXImageEditorViewController?
    private var editingAttachment : MediaAttachment!
    
    override func runWithMedia(media : MediaAttachment) -> Void {
        isRunning = true
        
        editingAttachment = media
        
        guard let image = media.image else {
            self.errorWithMessage(NSLocalizedString("No image provided for editing.", comment: ""))
            return
        }
        
        self.editingController = AdobeUXImageEditorViewController(image: image)
        
        self.editingController?.delegate = self
        
        self.presentingSubject?.onNext(self.editingController)
    }
}

extension AviaryEditProcessingTask : AdobeUXImageEditorViewControllerDelegate {
    
    @objc func photoEditor(editor: AdobeUXImageEditorViewController, finishedWithImage image: UIImage?) {
        
        editingController?.dismissViewControllerAnimated(true, completion: nil)
        
        
        guard let image = image, imageData = image.dataRepresentation() else {
            self.errorWithMessage(NSLocalizedString("There was an error while editing your image", comment: ""))
            return
        }
        
        let newAttachment = editingAttachment.mediaAttachmentWithExchangedImage(image, data: imageData)
        
        finish(newAttachment)
        
    }
    
    @objc func photoEditorCanceled(editor: AdobeUXImageEditorViewController) {
        finish(editingAttachment)
        
        editingController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
