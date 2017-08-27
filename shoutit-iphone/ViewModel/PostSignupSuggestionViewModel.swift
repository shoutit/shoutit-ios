//
//  PostSignupSuggestionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ShoutitKit

final class PostSignupSuggestionViewModel {
    
    fileprivate let disposeBag = DisposeBag()
    let state: Variable<LoadingState> = Variable(.idle)
    
    fileprivate(set) var usersSection: PostSignupSuggestionsSectionViewModel = PostSignupSuggestionsSectionViewModel(section: .users, models:[])
    fileprivate(set) var pagesSection: PostSignupSuggestionsSectionViewModel = PostSignupSuggestionsSectionViewModel(section: .pages, models:[])
    
    func fetchSections() {
        
        state.value = .loading
        
        guard let location = Account.sharedInstance.user?.location else {
            return
        }
        
        let params = SuggestionsParams(address: location, pageSize: 6, type: [.Users, .Pages], page: 0)
        APIMiscService
            .requestSuggestionsWithParams(params)
            .subscribe { (event) in
                switch event {
                case .next(let suggestions):
                    if let users = suggestions.users {
                        self.usersSection.updateCellsWithModels(users.map{$0 as Suggestable})
                    }
                    if let pages = suggestions.pages {
                        self.pagesSection.updateCellsWithModels(pages.map{$0 as Suggestable})
                    }
                    self.state.value = .contentLoaded
                case .error(let error):
                    self.state.value = .error(error)
                case .completed:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}
