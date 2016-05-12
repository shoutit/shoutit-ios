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

final class APIPublicChatsService {
    
    static func requestPublicChatsWithParams(params: ConversationsListParams, explicitURL: String? = nil) -> Observable<PagedResults<Conversation>> {
        let baseURL = APIManager.baseURL + "/public_chats"
        let url = explicitURL ?? baseURL
        let params: ConversationsListParams? = explicitURL == nil ? params : nil
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL, responseJsonPath: nil)
    }
}