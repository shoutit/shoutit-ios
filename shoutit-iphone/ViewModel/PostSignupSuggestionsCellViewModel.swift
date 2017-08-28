 //
//  PostSignupSuggestionsCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit
 
final class PostSignupSuggestionsCellViewModel {
    
    let item: Suggestable
    var selected: Bool = false
    
    let disposeBag = DisposeBag()
    
    init(item: Suggestable) {
        self.item = item
    }
    
    func listen() -> Observable<(successMessage: String?, error: Error?)> {

        let selected = !self.selected
        return Observable.create{[unowned self] (observer) -> Disposable in
            
            self.selected = selected
            observer.onNext((successMessage: nil, error: nil))
            APIProfileService.listen(selected, toProfileWithUsername: self.item.listenId).subscribe{[weak self] (event) in
                switch event {
                case .completed:
                    observer.onCompleted()
                case .error(let error):
                    self?.selected = !selected
                    observer.onNext((successMessage: nil, error: error))
                    observer.onCompleted()
                case .next(let success):
                    observer.onNext((successMessage: success.message, error: nil))
                }
            }.addDisposableTo(self.disposeBag)
            
            return Disposables.create {}
        }
    }
}
