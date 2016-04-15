//
//  ProfileCollectionPageCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ProfileCollectionListenableCellViewModel: ProfileCollectionCellViewModel {
    
    enum Model {
        case ProfileModel(profile: Profile)
        case TagModel(tag: Tag)
        
        var name: String {
            switch self {
            case .ProfileModel(let profile): return profile.name
            case .TagModel(let tag): return tag.name
            }
        }
    }
    
    let model: Model
    private(set) var isListening: Bool
    
    private let disposeBag = DisposeBag()
    
    init(profile: Profile) {
        self.model = .ProfileModel(profile: profile)
        self.isListening = profile.isListening ?? false
    }
    
    init(tag: Tag) {
        self.model = .TagModel(tag: tag)
        self.isListening = tag.isListening ?? false
    }
    
    func name() -> String {
        switch model {
        case .ProfileModel(let profile):
            return profile.name
        case .TagModel(let tag):
            return tag.name
        }
    }
    
    func thumbnailURL() -> NSURL? {
        switch model {
        case .ProfileModel(let profile):
            return profile.imagePath?.toURL()
        case .TagModel(let tag):
            return tag.imagePath?.toURL()
        }
    }
    
    func listeningCountString() -> String {
        let s: String
        switch model {
        case .ProfileModel(let profile):
            s = NumberFormatters.sharedInstance.numberToShortString(profile.listenersCount)
        case .TagModel(let tag):
            s = NumberFormatters.sharedInstance.numberToShortString(tag.listenersCount ?? 0)
        }
        return NSLocalizedString("\(s) Listeners", comment: "")
    }
    
    func hidesListeningButton() -> Bool {
        switch model {
        case .ProfileModel(let profile):
            return Account.sharedInstance.loggedUser?.id == profile.id
        case .TagModel:
            return false
        }
    }
    
    func toggleIsListening() -> Observable<(listening: Bool, successMessage: String?, error: ErrorType?)> {
        
        return Observable.create{ (observer) -> Disposable in
            
            self.isListening = !self.isListening
            observer.onNext((listening: self.isListening, successMessage: nil, error: nil))
            
            let subscribeBlock: (RxSwift.Event<Void> -> Void) = {(event) in
                switch event {
                case .Completed:
                    let message = self.isListening ? UserMessages.startedListeningMessageWithName(self.model.name) : UserMessages.stoppedListeningMessageWithName(self.model.name)
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
            
            switch self.model {
            case .ProfileModel(let profile):
                APIProfileService.listen(self.isListening, toProfileWithUsername: profile.username).subscribe(subscribeBlock).addDisposableTo(self.disposeBag)
            case .TagModel(let tag):
                APITagsService.listen(self.isListening, toTagWithName: tag.name).subscribe(subscribeBlock).addDisposableTo(self.disposeBag)
            }
            
            return NopDisposable.instance
        }
    }
}
