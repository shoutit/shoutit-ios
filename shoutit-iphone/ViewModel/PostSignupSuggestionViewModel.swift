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
    
    private let disposeBag = DisposeBag()
    let state: Variable<LoadingState> = Variable(.Idle)
    
    private(set) var usersSection: PostSignupSuggestionsSectionViewModel = PostSignupSuggestionsSectionViewModel(section: .Users, models:[])
    private(set) var pagesSection: PostSignupSuggestionsSectionViewModel = PostSignupSuggestionsSectionViewModel(section: .Pages, models:[])
    
    func fetchSections() {
        
        state.value = .Loading
        
        guard let location = Account.sharedInstance.user?.location else {
            return
        }
        
        let params = SuggestionsParams(address: location, pageSize: 6, type: [.Users, .Pages], page: 0)
        APIMiscService
            .requestSuggestionsWithParams(params)
            .subscribe { (event) in
                switch event {
                case .Next(let suggestions):
                    if let users = suggestions.users {
                        self.usersSection.updateCellsWithModels(users.map{$0 as Suggestable})
                    }
                    if let pages = suggestions.pages {
                        self.pagesSection.updateCellsWithModels(pages.map{$0 as Suggestable})
                    }
                    self.state.value = .ContentLoaded
                case .Error(let error):
                    self.state.value = .Error(error)
                case .Completed:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}