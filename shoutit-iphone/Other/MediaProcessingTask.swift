//
//  MediaProcessingTask.swift
//  shoutit
//
//  Created by Piotr Bernad on 06.07.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class MediaProcessingTask : NSObject {
    
    var finish : ((MediaAttachment) -> Void)!
   
    var isRunning : Bool = false
    
    var isGroupTask : Bool = false
    
    var uuid : String!
    
    weak var presentingSubject: PublishSubject<UIViewController?>?
    weak var errorSubject: PublishSubject<ErrorType?>?
    
    override init() {
        super.init()
        
        uuid = self.generateUUID()
    }
    
    override var hashValue: Int {
        get {
            return self.uuid.hashValue
        }
    }
    
    func runWithMedia(media : MediaAttachment) -> Void {
        isRunning = true
    }
    
    func runWithMedias(medias : [MediaAttachment]) -> Void {
        isRunning = true
    }
    
    func generateUUID() -> String {
        return NSUUID().UUIDString
    }
    
    func errorWithMessage(message: String) {
        self.errorSubject?.onNext(NSError(domain: "com.shoutit.mediaProcessing", code: 3002, userInfo: [NSLocalizedDescriptionKey: message]))
    }
}

func ==(lhs: MediaProcessingTask, rhs: MediaProcessingTask) -> Bool {
    return lhs.uuid == rhs.uuid
}
