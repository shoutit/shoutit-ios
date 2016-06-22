//
//  APICreditsService.swift
//  shoutit
//
//  Created by Piotr Bernad on 13/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

final class APICreditsService {
    
    private static let transactionsURL = APIManager.baseURL + "/credit/transactions"
    private static let invitationCodeURL = APIManager.baseURL + "/credit/invitation_code"

    
    static func requestInvitationCode() -> Observable<InvitationCode> {
        return APIGenericService.requestWithMethod(.GET, url: invitationCodeURL, params: NopParams(), encoding: .URL, responseJsonPath:nil)
    }
}