//
//  MediaUploadingTask.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

enum MediaUploadingTaskStatus : Int {
    case Uploading
    case Uploaded
    case Error
}

final class MediaUploadingTask: NSObject {
    
    var attachment : MediaAttachment
    var request : Alamofire.Request? {
        didSet {
            trackProgress()
            trackError()
            logActivity()
        }
    }
    
    var uid : String!
    
    var status : Variable<MediaUploadingTaskStatus> = Variable(.Uploading)
    var progress : Variable<Float> = Variable(0)
    
    required init(attachment: MediaAttachment) {
        self.attachment = attachment
        self.uid = NSUUID().UUIDString
        super.init()
    }
    
    func changeStatusTo(status: MediaUploadingTaskStatus) {
        self.status.value = status
        
        debugPrint(request)
    }
    
    func trackProgress() {
        request?.progress({ [weak self] (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
            let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
            self?.progress.value = percent
        })
    }
    
    func trackError() {
        if let request = request {
            request.response(completionHandler: { (request, response, data, error) -> Void in
                if let _ = error {
                    self.changeStatusTo(.Error)
                    return
                }
                
                if let _ = response {
                    self.changeStatusTo(.Uploaded)
                    
                    return
                }

            })
        }
    }
    
    func logActivity() {
        if let request = request {
            print(request)
        }
    }
}
