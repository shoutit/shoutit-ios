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
import ShoutitKit

final class APICreditsService {
    
    fileprivate static let transactionsURL = APIManager.baseURL + "/credit/transactions"
    fileprivate static let invitationCodeURL = APIManager.baseURL + "/credit/invitation_code"
    
    static func requestTransactions(_ type: String = "in", before: Int?) -> Observable<[Transaction]> {
        return APIGenericService.requestWithMethod(.GET, url: transactionsURL, params: BeforeTimestampParams(beforeTimeStamp: before), encoding: .url, responseJsonPath: ["results"])
    }

    static func requestInvitationCode() -> Observable<InvitationCode> {
        return APIGenericService.requestWithMethod(.GET, url: invitationCodeURL, params: NopParams(), encoding: .url, responseJsonPath:nil)
    }
}
