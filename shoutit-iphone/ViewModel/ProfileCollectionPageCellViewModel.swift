//
//  ProfileCollectionPageCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ProfileCollectionPageCellViewModel: ProfileCollectionCellViewModel {
    
    let profile: Profile
    private(set) var isListening: Bool
    
    let disposeBag = DisposeBag()
    
    init(profile: Profile) {
        self.profile = profile
        self.isListening = profile.listening ?? false
    }
    
    func listeningCountString() -> String {
        let numberString = NumberFormatters.sharedInstance.numberToShortString(profile.listenersCount)
        return NSLocalizedString("\(numberString) Listeners", comment: "")
    }
    
    func toggleIsListening() -> Observable<Bool> {
        
        return Observable.create{ (observer) -> Disposable in
            
            self.isListening = !self.isListening
            observer.onNext(self.isListening)
            
            APIProfileService.listen(self.isListening, toProfileWithUsername: self.profile.username).subscribe{ (event) in
                switch event {
                case .Completed:
                    observer.onNext(self.isListening)
                case .Error(let error):
                    self.isListening = !self.isListening
                    observer.onNext(self.isListening)
                    observer.onError(error)
                default:
                    break
                }
                observer.onCompleted()
            }.addDisposableTo(self.disposeBag)
            
            return NopDisposable.instance
        }
    }
}
