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
        self.isListening = profile.listening ?? false
    }
    
    func listeningCountString() -> String {
        return NSLocalizedString("\(NumberFormatters.sharedInstance.numberToShortString(profile.listenersCount)) Listeners", comment: "")
    }
    
    func hidesListeningButton() -> Bool {
        return Account.sharedInstance.loggedUser?.id == profile.id
    }
    
    func toggleIsListening() -> Observable<Bool> {
        
        return Observable.create{[weak self] (observer) -> Disposable in
            
            guard let strongSelf = self else {
                return NopDisposable.instance
            }
            
            strongSelf.isListening = !strongSelf.isListening
            observer.onNext(strongSelf.isListening)
            
            let subscribeBlock: (RxSwift.Event<Void> -> Void) = {(event) in
                switch event {
                case .Completed:
                    observer.onNext(strongSelf.isListening)
                case .Error(let error):
                    strongSelf.isListening = !strongSelf.isListening
                    observer.onNext(strongSelf.isListening)
                    observer.onError(error)
                default:
                    break
                }
                observer.onCompleted()
            }
            
            return APIProfileService.listen(strongSelf.isListening, toProfileWithUsername: strongSelf.profile.username).subscribe(subscribeBlock)
        }
    }
}
