 //
//  PostSignupSuggestionsCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class PostSignupSuggestionsCellViewModel {
    
    let item: Suggestable
    var selected: Bool = false
    
    let disposeBag = DisposeBag()
    
    init(item: Suggestable) {
        self.item = item
    }
    
    func listen() -> Observable<(successMessage: String?, error: ErrorType?)> {

        let selected = !self.selected
        return Observable.create{[unowned self] (observer) -> Disposable in
            
            self.selected = selected
            observer.onNext((successMessage: nil, error: nil))
            APIProfileService.listen(selected, toProfileWithUsername: self.item.listenId).subscribe{[weak self] (event) in
                switch event {
                case .Completed:
                    observer.onCompleted()
                case .Error(let error):
                    self?.selected = !selected
                    observer.onNext((successMessage: nil, error: error))
                    observer.onCompleted()
                case .Next:
                    guard let `self` = self else { return }
                    let message = self.selected ? UserMessages.startedListeningMessageWithName(self.item.suggestionTitle) : UserMessages.stoppedListeningMessageWithName(self.item.suggestionTitle)
                    observer.onNext((successMessage: message, error: nil))
                }
            }.addDisposableTo(self.disposeBag)
            
            return NopDisposable.instance
        }
    }
}
