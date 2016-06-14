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
    
    private static let transactionsURL = APIManager.baseURL + "/credit/transactions"

    // MARK: - Traditional
    
    static func requestTransactions(type: String = "in", before: Int?) -> Observable<[Transaction]> {
        return APIGenericService.requestWithMethod(.GET, url: transactionsURL, params: BeforeTimestampParams(beforeTimeStamp: before), encoding: .URL, responseJsonPath: ["results"])
    }
}