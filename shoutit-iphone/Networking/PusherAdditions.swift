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

public extension JSONDecodable {
    init(JSONData: Data) throws {
        let result = try JSONSerialization.jsonObject(with: JSONData, options: JSONSerialization.ReadingOptions(rawValue: 0))
        
        guard let converted = result as? [String: AnyObject] else {
            throw JSONDecodableError.dictionaryTypeExpectedError(key: "n/a", elementType: type(of: result))
        }
        
        try self.init(object: converted)
    }
}

extension PTPusherEvent {
    
    func eventType() -> PusherEventType {
        guard let type = PusherEventType(rawValue: self.name) else {
            fatalError("Pusher Event not supported. Event Name: \(self.name)")
        }
        
        return type
    }
    
    func object<T: JSONDecodable>() -> T? {
        
        guard let data = self.data as? JSONObject else {
            return nil }
        do {
            
            let decoded: T = try T(object: data)
            return decoded
        } catch let error {
            debugPrint("Could not parse pusher object \(error)")
            return nil
        }
    }
}

