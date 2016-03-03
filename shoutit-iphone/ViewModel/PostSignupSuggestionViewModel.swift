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

class PostSignupSuggestionViewModel {
    
    private let disposeBag = DisposeBag()
    let state: Variable<LoadingState> = Variable(.Idle)
    
    private(set) var usersSection: PostSignupSuggestionsSectionViewModel<Profile> = PostSignupSuggestionsSectionViewModel<Profile>(section: .Users, models:[])
    private(set) var pagesSection: PostSignupSuggestionsSectionViewModel<Profile> = PostSignupSuggestionsSectionViewModel<Profile>(section: .Pages, models:[])
    
    func fetchSections() {
        
        state.value = .Loading
        let params = SuggestionsParams(address: Account.sharedInstance.user!.location, pageSize: 6, type: [.Users, .Pages])
        APIMiscService
            .requestSuggestionsWithParams(params)
            .subscribe { (event) in
                switch event {
                case .Next(let suggestions):
                    if let users = suggestions.users {
                        let usersSection = PostSignupSuggestionsSectionViewModel(section: .Users, models: users)
                        self.usersSection = usersSection
                    }
                    if let pages = suggestions.pages {
                        let pagesSection = PostSignupSuggestionsSectionViewModel(section: .Pages, models: pages)
                        self.pagesSection = pagesSection
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