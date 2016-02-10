//
//  PostSignupSuggestionsSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum PostSignupSuggestionsSection {
    case Users
    case Pages
    case Interests
    
    var title: String {
        switch self {
        case .Users:
            return NSLocalizedString("Suggested Users", comment: "")
        case .Pages:
            return NSLocalizedString("Suggested Pages", comment: "")
        case .Interests:
            return NSLocalizedString("Suggested Interests", comment: "")
        }
    }
}

class PostSignupSuggestionsSectionViewModel {
    
    let section: PostSignupSuggestionsSection
    var cells: [PostSignupSuggestionsCellViewModel]
    
    init(section: PostSignupSuggestionsSection, models: [Suggestable]) {
        self.section = section
        let headerCellViewModel = PostSignupSuggestionsCellViewModel(sectionTitle: section.title)
        self.cells = [headerCellViewModel] + models.map{PostSignupSuggestionsCellViewModel(item: $0)}
    }
}
