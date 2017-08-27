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
        case profileModel(profile: Profile)
        case tagModel(tag: Tag)
        
        var name: String {
            switch self {
            case .profileModel(let profile): return profile.name
            case .tagModel(let tag): return tag.name
            }
        }
    }
    
    var model: Model
    fileprivate(set) var isListening: Bool
    
    fileprivate let disposeBag = DisposeBag()
    
    init(profile: Profile) {
        self.model = .profileModel(profile: profile)
        self.isListening = profile.isListening ?? false
    }
    
    init(tag: Tag) {
        self.model = .tagModel(tag: tag)
        self.isListening = tag.isListening ?? false
    }
    
    func name() -> String {
        switch model {
        case .profileModel(let profile):
            return profile.name
        case .tagModel(let tag):
            return tag.name
        }
    }
    
    func thumbnailURL() -> URL? {
        switch model {
        case .profileModel(let profile):
            return profile.imagePath?.toURL()
        case .tagModel(let tag):
            return tag.imagePath?.toURL()
        }
    }
    
    func listeningCountString() -> String {
        let s: String
        switch model {
        case .profileModel(let profile):
            s = NumberFormatters.numberToShortString(profile.listenersCount)
        case .tagModel(let tag):
            s = NumberFormatters.numberToShortString(tag.listenersCount ?? 0)

        }
        return String.localizedStringWithFormat(NSLocalizedString("%@ Listeners", comment: "Listners Count"), s)
    }
    
    func updateListnersCount(_ newListnersCount: Int, isListening: Bool) {
        switch model {
        case .profileModel(let profile):
            self.model = .profileModel(profile: profile.copyWithListnersCount(newListnersCount, isListening: isListening))
        case .tagModel(let tag):
            self.model = .tagModel(tag: tag.copyWithListnersCount(newListnersCount, isListening: isListening))
            
        }
    }
    
    func hidesListeningButton() -> Bool {
        switch model {
        case .profileModel(let profile):
            return Account.sharedInstance.user?.id == profile.id
        case .tagModel:
            return false
        }
    }
    
    func toggleIsListening() -> Observable<(listening: Bool, successMessage: String?, listnersCount: Int?, error: Error?)> {
        
        return Observable.create{ (observer) -> Disposable in
            
            self.isListening = !self.isListening
            observer.onNext((listening: self.isListening, successMessage: nil, listnersCount: nil, error: nil))
            
            let subscribeBlock: ((RxSwift.Event<ListenSuccess>) -> Void) = {(event) in
                switch event {
                case .next(let success):
                    observer.onNext((listening: self.isListening, successMessage: success.message, listnersCount: success.newListnersCount, error: nil))
                    observer.onCompleted()
                case .error(let error):
                    self.isListening = !self.isListening
                    observer.onNext((listening: self.isListening, successMessage: nil, listnersCount: nil, error: error))
                    observer.onError(error)
                default:
                    break
                }
            }
            
            switch self.model {
            case .profileModel(let profile):
                APIProfileService.listen(self.isListening, toProfileWithUsername: profile.username).subscribe(subscribeBlock).addDisposableTo(self.disposeBag)
            case .tagModel(let tag):
                APITagsService.listen(self.isListening, toTagWithSlug: tag.slug).subscribe(subscribeBlock).addDisposableTo(self.disposeBag)
            }
            
            return NopDisposable.instance
        }
    }
}
