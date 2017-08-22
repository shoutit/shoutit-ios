//
//  APINotificationsService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import ShoutitKit

final class APINotificationsService {
    
    fileprivate static let notificationsURL = APIManager.baseURL + "/notifications"
    fileprivate static let resetNotificationsURL = APIManager.baseURL + "/notifications/reset"
    
    // MARK: - Traditional
    
    static func requestNotificationsBefore(_ before: Int?) -> Observable<[ShoutitKit.Notification]> {
        return APIGenericService.requestWithMethod(.GET, url: notificationsURL, params: BeforeTimestampParams(beforeTimeStamp: before), encoding: .url, responseJsonPath: ["results"])
    }
    
    static func markNotificationAsRead(_ notification: ShoutitKit.Notification) -> Observable<Void> {
        let url = APIManager.baseURL + "/notifications/\(notification.id)/read"
        
        return APIGenericService.basicRequestWithMethod(.POST, url: url, params: NopParams(), encoding: .url, headers: nil)
    }
    
    static func markAllAsRead() -> Observable<Void> {
        return APIGenericService.basicRequestWithMethod(.POST, url: resetNotificationsURL, params: NopParams(), encoding: .url, headers: nil)
    }
}
