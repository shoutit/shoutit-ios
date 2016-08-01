//
//  ProfileCollectionPageCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class ProfileCollectionListenableCellViewModel: ProfileCollectionCellViewModel {
    
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
    
    var model: Model
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
            s = NumberFormatters.numberToShortString(profile.listenersCount)
        case .TagModel(let tag):
            s = NumberFormatters.numberToShortString(tag.listenersCount ?? 0)

        }
        return String.localizedStringWithFormat(NSLocalizedString("%@ Listeners", comment: ""), s)
    }
    
    func updateListnersCount(newListnersCount: Int, isListening: Bool) {
        switch model {
        case .ProfileModel(let profile):
            self.model = .ProfileModel(profile: profile.copyWithListnersCount(newListnersCount, isListening: isListening))
        case .TagModel(let tag):
            self.model = .TagModel(tag: tag.copyWithListnersCount(newListnersCount, isListening: isListening))
            
        }
    }
    
    func hidesListeningButton() -> Bool {
        switch model {
        case .ProfileModel(let profile):
            return Account.sharedInstance.user?.id == profile.id
        case .TagModel:
            return false
        }
    }
    
    func toggleIsListening() -> Observable<(listening: Bool, successMessage: String?, listnersCount: Int?, error: ErrorType?)> {
        
        return Observable.create{ (observer) -> Disposable in
            
            self.isListening = !self.isListening
            observer.onNext((listening: self.isListening, successMessage: nil, listnersCount: nil, error: nil))
            
            let subscribeBlock: (RxSwift.Event<ListenSuccess> -> Void) = {(event) in
                switch event {
                case .Next(let success):
                    observer.onNext((listening: self.isListening, successMessage: success.message, listnersCount: success.newListnersCount, error: nil))
                    observer.onCompleted()
                case .Error(let error):
                    self.isListening = !self.isListening
                    observer.onNext((listening: self.isListening, successMessage: nil, listnersCount: nil, error: error))
                    observer.onError(error)
                default:
                    break
                }
            }
            
            switch self.model {
            case .ProfileModel(let profile):
                APIProfileService.listen(self.isListening, toProfileWithUsername: profile.username).subscribe(subscribeBlock).addDisposableTo(self.disposeBag)
            case .TagModel(let tag):
                APITagsService.listen(self.isListening, toTagWithSlug: tag.slug).subscribe(subscribeBlock).addDisposableTo(self.disposeBag)
            }
            
            return NopDisposable.instance
        }
    }
}
