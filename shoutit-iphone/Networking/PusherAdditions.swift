//
//  PusherAdditions.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Pusher
import Argo

enum PusherEventType : String {
    
    case NewMessage = "new_message"
    case NewListen = "new_listen"
    case ProfileChange = "profile_change"
    case UserTyping = "client-is_typing"
    case JoinedChat = "client-joined_chat"
    case LeftChat = "client-left_chat"
}

extension PTPusherEvent {
    
    func eventType() -> PusherEventType {
        guard let type = PusherEventType(rawValue: self.name) else {
            fatalError("Pusher Event not supported. Event Name: \(self.name)")
        }
        
        return type
    }
    
    func object<T: Decodable where T == T.DecodedType>() -> T? {
        
        let decoded: Decoded<T> = decode(self.data)

        switch decoded {
        case .Success(let object):
            return object
        case .Failure(let decodeError):
            debugPrint("Could not parse pusher object \(decodeError)")
            return nil
        }
    }
}

