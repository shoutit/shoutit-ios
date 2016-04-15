//
//  SearchUserProfileCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class SearchUserProfileCellViewModel {
    
    let profile: Profile
    var isListening: Bool
    
    init(profile: Profile) {
        self.profile = profile
        self.isListening = profile.isListening ?? false
    }
    
    func listeningCountString() -> String {
        return NSLocalizedString("\(NumberFormatters.sharedInstance.numberToShortString(profile.listenersCount)) Listeners", comment: "")
    }
    
    func hidesListeningButton() -> Bool {
        return Account.sharedInstance.loggedUser?.id == profile.id
    }
    
    func toggleIsListening() -> Observable<(listening: Bool, successMessage: String?, error: ErrorType?)> {
        
        return Observable.create{[weak self] (observer) -> Disposable in
            
            guard let `self` = self else {
                return NopDisposable.instance
            }
            
            self.isListening = !self.isListening
            observer.onNext((listening: self.isListening, successMessage: nil, error: nil))
            
            let subscribeBlock: (RxSwift.Event<Void> -> Void) = {(event) in
                switch event {
                case .Completed:
                    let message = self.isListening ? UserMessages.startedListeningMessageWithName(self.profile.name) : UserMessages.stoppedListeningMessageWithName(self.profile.name)
                    observer.onNext((listening: self.isListening, successMessage: message, error: nil))
                    observer.onCompleted()
                case .Error(let error):
                    self.isListening = !self.isListening
                    observer.onNext((listening: self.isListening, successMessage: nil, error: error))
                    observer.onError(error)
                default:
                    break
                }
            }
            
            return APIProfileService.listen(self.isListening, toProfileWithUsername: self.profile.username).subscribe(subscribeBlock)
        }
    }
}
