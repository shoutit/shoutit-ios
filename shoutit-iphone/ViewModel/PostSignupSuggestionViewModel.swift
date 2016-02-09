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
    
    let state: Variable<LoadingState> = Variable(.Idle)
    
    var sections: [PostSignupSuggestionsSectionViewModel] = []
    
    func fetchSections() {
        
        state.value = .Loading
        let params = SuggestionsParams(address: Account.sharedInstance.user!.location, pageSize: 3, type: [.Users, .Pages, .Tags])
        APIMiscService.requestSuggestionsWithParams(params) { (result) in
            switch result {
            case .Success(let suggestions):
                var sections = [PostSignupSuggestionsSectionViewModel]()
                if let users = suggestions.users {
                    let usersSection = PostSignupSuggestionsSectionViewModel(section: .Users, models: users.map{$0 as Suggestable})
                    sections.append(usersSection)
                }
                if let pages = suggestions.pages {
                    let pagesSection = PostSignupSuggestionsSectionViewModel(section: .Pages, models: pages.map{$0 as Suggestable})
                    sections.append(pagesSection)
                }
                if let tags = suggestions.tags {
                    let tagsSection = PostSignupSuggestionsSectionViewModel(section: .Interests, models: tags.map{$0 as Suggestable})
                    sections.append(tagsSection)
                }
            case .Failure(let error):
                self.state.value = .Error(error)
            }
        }
    }
}