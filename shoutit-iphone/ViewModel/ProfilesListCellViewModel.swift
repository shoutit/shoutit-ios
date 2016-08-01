//
//  ProfilesListCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class ProfilesListCellViewModel: Listenable {
    
    let profile: Profile
    var isListening: Bool
    var startedListeningMessage: String { return UserMessages.startedListeningMessageWithName(self.profile.name) }
    var stoppedListeningMessage: String { return UserMessages.stoppedListeningMessageWithName(self.profile.name) }
    
    init(profile: Profile) {
        self.profile = profile
        self.isListening = profile.isListening ?? false
    }
    
    func listeningCountString() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("%@ Listeners", comment: ""), NumberFormatters.numberToShortString(profile.listenersCount))
    }
    
    func hidesListeningButton() -> Bool {
        return Account.sharedInstance.user?.id == profile.id
    }
    
    func listenRequestObservable() -> Observable<ListenSuccess> {
        return APIProfileService.listen(self.isListening, toProfileWithUsername: self.profile.username)
    }
}
