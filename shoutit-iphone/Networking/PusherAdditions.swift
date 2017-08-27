//
//  PusherAdditions.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

enum PusherEventType : String {
    
    case NewMessage = "new_message"
    case NewListen = "new_listen"
    case ProfileChange = "profile_update"
    case UserTyping = "client-is_typing"
    case JoinedChat = "client-joined_chat"
    case LeftChat = "client-left_chat"
    case StatsUpdate = "stats_update"
    case ConversationUpdate = "conversation_update"
    case NewNotification = "new_notification"
}

extension PTPusherEvent {
    
    func eventType() -> PusherEventType {
        guard let type = PusherEventType(rawValue: self.name) else {
            fatalError("Pusher Event not supported. Event Name: \(self.name)")
        }
        
        return type
    }
    
//    func object<T: Decodable>() -> T? where T == T.DecodedType {
//        
//        let decoded: Decoded<T> = decode(self.data)
//
//        switch decoded {
//        case .Success(let object):
//            return object
//        case .Failure(let decodeError):
//            debugPrint("Could not parse pusher object \(decodeError)")
//            debugPrint(self.data)
//            return nil
//        }
//    }
}

