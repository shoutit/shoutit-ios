//
//  ConversationSubjectEditable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 20.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol ConversationSubjectEditable: class {
    var chatSubject: String { get set }
    var imageUploadTask: MediaUploadingTask? { get }
    var mediaUploader: MediaUploader { get }
}

extension ConversationSubjectEditable {
    
    func validateFields() throws {
        if let task = imageUploadTask, task.status.value == .uploading {
            throw LightError(userMessage:LocalizedString.Media.waitUntilUpload)
        }
        
        if chatSubject.utf16.count < 1 {
            throw LightError(userMessage: NSLocalizedString("Please enter chat subject", comment: "Create Public Chat Message"))
        }
    }

}
