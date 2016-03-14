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
    
    func listen() -> Observable<Void> {

        let selected = !self.selected
        return Observable.create{[unowned self] (observer) -> Disposable in
            
            self.selected = selected
            observer.onNext()
            APIProfileService.listen(selected, toProfileWithUsername: self.item.listenId).subscribe{[weak self] (event) in
                switch event {
                case .Completed:
                    observer.onCompleted()
                case .Error:
                    self?.selected = !selected
                    observer.onNext()
                    observer.onCompleted()
                case .Next:
                    break
                }
            }.addDisposableTo(self.disposeBag)
            
            return NopDisposable.instance
        }
    }
}
