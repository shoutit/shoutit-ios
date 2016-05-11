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

final class APINotificationsService {
    
    private static let notificationsURL = APIManager.baseURL + "/notifications"
    private static let resetNotificationsURL = APIManager.baseURL + "/notifications/reset"
    
    // MARK: - Traditional
    
    static func requestNotificationsBefore(before: Int?) -> Observable<[Notification]> {
        return APIGenericService.requestWithMethod(.GET, url: notificationsURL, params: BeforeTimestampParams(beforeTimeStamp: before), encoding: .URL, responseJsonPath: ["results"])
    }
    
    static func markNotificationAsRead(notification: Notification) -> Observable<Notification> {
        let url = APIManager.baseURL + "/notifications/\(notification.id)/read"
        
        return APIGenericService.requestWithMethod(.POST, url: url, params: NopParams())
    }
    
    static func markAllAsRead() -> Observable<Void> {
        return APIGenericService.basicRequestWithMethod(.POST, url: resetNotificationsURL, params: NopParams(), encoding: .URL, headers: nil)
    }
}