//
//  APIChatsService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class APIChatsService {
    private static let conversationsURL = APIManager.baseURL + "/conversations"

    // MARK: - Traditional

    static func requestConversations() -> Observable<[Conversation]> {
        return APIGenericService.requestWithMethod(.GET, url: conversationsURL, params: NopParams(), encoding: .URL, responseJsonPath: ["results"])
    }
    
    /*
    static func startConversationWithUsername(username: String) -> Observable<Conversation> {
        
    }
    */
}