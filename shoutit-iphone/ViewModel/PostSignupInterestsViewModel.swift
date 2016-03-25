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

class PostSignupInterestsViewModel {
    
    let state: Variable<LoadingState> = Variable(.Idle)
    private(set) var categories: Variable<[PostSignupInterestCellViewModel]> = Variable([])
    
    func fetchCategories() {
        
        state.value = .Loading
        APIMiscService.requestCategoriesWithCompletionHandler() {(result) in
            switch result {
            case .Success(let categories):
                self.categories.value = categories.map{PostSignupInterestCellViewModel(category: $0)}
                self.state.value = self.categories.value.count > 0 ? .ContentLoaded : .ContentUnavailable
            case .Failure(let error):
                self.state.value = .Error(error)
            }
        }
    }
    
    func listenToSelectedCategories() -> Observable<Void> {
        let tagNames = categories.value.filter{$0.selected}.map{$0.category.mainTag.name}
        let params = BatchListenParams(tagNames: tagNames)
        return APITagsService.requestBatchListenTagWithParams(params)
    }
}
