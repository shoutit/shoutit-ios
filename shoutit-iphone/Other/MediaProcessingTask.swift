//
//  MediaProcessingTask.swift
//  shoutit
//
//  Created by Piotr Bernad on 06.07.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation


class MediaProcessingTask : Equatable, Hashable {
    
    var finish : (Void -> Void)!
   
    var isRunning : Bool = false
    
    var uuid : String!
    
    var hashValue: Int {
        get {
            return self.uuid.hashValue
        }
    }
    
    func runWithMedia(media : MediaAttachment) -> Void {
        isRunning = true
    }
    
    func generateUUID() -> String {
        return NSUUID().UUIDString
    }
    
}

func ==(lhs: MediaProcessingTask, rhs: MediaProcessingTask) -> Bool {
    return lhs.uuid == rhs.uuid
}
