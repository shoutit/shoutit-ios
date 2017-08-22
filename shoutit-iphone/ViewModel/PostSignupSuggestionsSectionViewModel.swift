//
//  PostSignupSuggestionsSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

enum PostSignupSuggestionsSection {
    case users
    case pages
    
    var title: String {
        switch self {
        case .users:
            return NSLocalizedString("Suggested Users", comment: "Post Signup Suggestions Title")
        case .pages:
            return NSLocalizedString("Suggested Pages", comment: "Post Signup Suggestions Title")
        }
    }
    
    
}

final class PostSignupSuggestionsSectionViewModel {
    
    let section: PostSignupSuggestionsSection
    fileprivate(set) var cells: [PostSignupSuggestionsCellViewModel]
    
    init(section: PostSignupSuggestionsSection, models: [Suggestable]) {
        self.section = section
        self.cells = models.map{PostSignupSuggestionsCellViewModel(item: $0)}
    }
    
    func updateCellsWithModels(_ models: [Suggestable]) {
        self.cells = models.map{PostSignupSuggestionsCellViewModel(item: $0)}
    }
    
    var noContentTitle: String {
        return NSLocalizedString("There is no suggestions for you at the moment", comment: "No Suggestions")
    }
}
