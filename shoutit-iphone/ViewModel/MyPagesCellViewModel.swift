//
//  MyPagesCellViewModel.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 24.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

class MyPagesCellViewModel {
    
    let profile: Profile
    
    init(profile: Profile) {
        self.profile = profile
    }
    
    func listeningCountString() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("%@ Listeners", comment: ""), NumberFormatters.numberToShortString(profile.listenersCount))
    }
    
    func detailTextString() -> String? {
        return profile.location?.city
    }
    
    func notificationsCountString() -> String? {
        if let notificationsCount = profile.stats?.totalUnreadCount where notificationsCount > 0 {
            return NumberFormatters.badgeCountStringWithNumber(notificationsCount)
        } else {
            return nil
        }
    }
}
