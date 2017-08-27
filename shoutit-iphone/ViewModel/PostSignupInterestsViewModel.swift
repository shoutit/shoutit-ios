//
//  PostSignupInterestsViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa
import ShoutitKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


final class PostSignupInterestsViewModel {
    
    fileprivate let disposeBag = DisposeBag()
    let state: Variable<LoadingState> = Variable(.idle)
    fileprivate(set) var categories: Variable<[PostSignupInterestCellViewModel]> = Variable([])
    
    func fetchCategories() {
        
        state.value = .loading
        APIMiscService.requestCategories().subscribe {[weak self] (event) in
            switch event {
            case .next(let categories):
                self?.categories.value = categories.map{PostSignupInterestCellViewModel(category: $0)}
                self?.state.value = self?.categories.value.count > 0 ? .contentLoaded : .contentUnavailable
            case .error(let error):
                self?.state.value = .error(error)
            default:
                break
            }
        }
        .addDisposableTo(disposeBag)
    }
    
    func listenToSelectedCategories() -> Observable<Void> {
        let tagNames = categories.value.filter{$0.selected}.map{$0.category.slug}
        let params = BatchListenParams(tagSlugs: tagNames)
        return APITagsService.requestBatchListenTagWithParams(params)
    }
}
