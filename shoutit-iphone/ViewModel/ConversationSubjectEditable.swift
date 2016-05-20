//
//  ConversationSubjectEditable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 20.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol ConversationSubjectEditable: class {
    var chatSubject: String { get set }
    var imageUploadTask: MediaUploadingTask? { get }
    var mediaUploader: MediaUploader { get }
}

extension ConversationSubjectEditable {
    
    func validateFields() throws {
        if let task = imageUploadTask where task.status.value == .Uploading {
            throw LightError(userMessage: NSLocalizedString("Please wait for upload to finish", comment: ""))
        }
        
        if chatSubject.utf16.count < 1 {
            throw LightError(userMessage: NSLocalizedString("Please enter chat subject", comment: ""))
        }
    }

}