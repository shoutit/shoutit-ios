 //
//  PostSignupSuggestionsCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

enum PostSignupSuggestionsCellType {
    case Header(title: String)
    case Normal(item: Suggestable)
    
    var reuseIdentifier: String {
        switch self {
        case .Header(title: _):
            return "PostSignupSuggestionsHeaderTableViewCell"
        case .Normal(item: _):
            return "PostSignupSuggestionsTableViewCell"
        }
    }
}

class PostSignupSuggestionsCellViewModel {
    
    let cellType: PostSignupSuggestionsCellType
    var item: Suggestable? {
        if case PostSignupSuggestionsCellType.Normal(let item) = self.cellType {
            return item
        }
        return nil
    }
    var selected: Bool = false
    
    let disposeBag = DisposeBag()
    
    init(item: Suggestable) {
        self.cellType = .Normal(item: item)
    }
    
    init(sectionTitle: String) {
        self.cellType = .Header(title: sectionTitle)
    }
    
    func listen() -> Observable<Void> {
        guard let item = item else {
            fatalError()
        }
        let selected = !self.selected
        return Observable.create{[weak self] (observer) -> Disposable in
            self?.selected = selected
            observer.onNext()
            APIProfileService.listen(selected, toProfileWithUsername: item.listenId).subscribe{ (event) in
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
            }.addDisposableTo(self!.disposeBag)
            
            return NopDisposable.instance
        }
    }
}
