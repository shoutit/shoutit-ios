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
import AmazonS3RequestManager

enum MediaUploadingTaskStatus : Int {
    case uploading
    case uploaded
    case error
}

final class MediaUploadingTask: NSObject {
    
    var attachment : MediaAttachment
    var request : UploadRequest? {
        didSet {
            trackProgress()
            trackError()
            logActivity()
        }
    }
    
    var uid : String!
    
    var status : Variable<MediaUploadingTaskStatus> = Variable(.uploading)
    var progress : Variable<Float> = Variable(0)
    
    required init(attachment: MediaAttachment) {
        self.attachment = attachment
        self.uid = UUID().uuidString
        super.init()
    }
    
    func changeStatusTo(_ status: MediaUploadingTaskStatus) {
        self.status.value = status
        
        debugPrint(request)
    }
    
    func trackProgress() {
        
        request?.uploadProgress(closure: { [weak self] (p) in
            let percent = Float(p.fractionCompleted)
            self?.progress.value = percent
        })
    }
    
    func trackError() {
        if let request = request {
            request.response(completionHandler: { (dr) in
                if let _ = dr.error {
                    self.changeStatusTo(.error)
                    return
                }
                
                if let _ = dr.response {
                    self.changeStatusTo(.uploaded)
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
