//
//  NotificationManager.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class NotificationManager: AnyObject {
    
    static let sharedManager = NotificationManager()
    
    var notificationsSubject = PublishSubject<[Notification]>()
    var unreadNotificationsCountSubject = PublishSubject<Int>()
    
    private let disposeBag = DisposeBag()
    
    func triggerNotificationsRefresh() {
        APINotificationsService.requestNotifications().subscribeNext { [weak self] (notifications) in
            
            let unread = self?.countUnreadNotifications(notifications)
            self?.unreadNotificationsCountSubject.onNext(unread ?? 0)
            self?.notificationsSubject.onNext(notifications)
            
        }.addDisposableTo(disposeBag)
    }
    
    private func countUnreadNotifications(notifications: [Notification]) -> Int {
        return notifications.filter { (notification) -> Bool in
            return notification.read == false
        }.count
    }
    
}
