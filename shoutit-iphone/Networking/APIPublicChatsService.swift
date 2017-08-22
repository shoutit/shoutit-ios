//
//  APIPublicChatsService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import ShoutitKit

final class APIPublicChatsService {
    
    static func requestPublicChatsWithParams(_ params: ConversationsListParams, explicitURL: String? = nil) -> Observable<PagedResults<MiniConversation>> {
        let baseURL = APIManager.baseURL + "/public_chats"
        let url = explicitURL ?? baseURL
        let params: ConversationsListParams? = explicitURL == nil ? params : nil
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .url, responseJsonPath: nil)
    }
    
    static func requestCreatePublicChatWithParams(_ params: CreatePublicChatParams) -> Observable<Conversation> {
        let url = APIManager.baseURL + "/public_chats"
        return APIGenericService.requestWithMethod(.POST, url: url, params: params, encoding: .json)
    }
}
