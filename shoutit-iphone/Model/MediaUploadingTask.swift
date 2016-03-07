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

class MediaUploadingTask: NSObject {
    
    var attachment : MediaAttachment!
    var request : Alamofire.Request? {
        didSet {
            trackProgress()
            trackError()
            logActivity()
        }
    }
    
    var uid : String!
    var status = MediaUploadingTaskStatus.Uploading
    var progress : Variable<Float> = Variable(0)
    
    required init(attachment: MediaAttachment) {
        super.init()
        self.attachment = attachment
        self.uid = generateUid()
    }
    
    func generateUid() -> String {
        return NSUUID().UUIDString
    }
    
    func changeStatusTo(status: MediaUploadingTaskStatus) {
        self.status = status
        debugPrint(request)
    }
    
    func trackProgress() {
        request?.progress({ [weak self] (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
            
            let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
            
            print("Uploading: \(percent)")
            
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
